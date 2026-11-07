# Healthcare Suite Technical KT

## 1. Scope

This KT covers the current codebase under `backend/` and `frontend/` as reviewed on 2026-03-26.

What this document is meant to do:

- explain the full system shape end to end
- show how backend modules are split and then reassembled in the unified FastAPI app
- map frontend routes to stores, API helpers, and backend dependencies
- highlight the important operational caveats and current-state gaps
- give you a presenter-ready talk track for the handoff session

For the exhaustive function and route inventory, use [TECHNICAL_KT_APPENDIX.md](TECHNICAL_KT_APPENDIX.md).

## 2. Executive Summary

The repo is a multi-portal healthcare platform with four backend domains:

1. `ehr`: the main API shell and the core clinical API layer
2. `reg_and_sched`: patient registration, doctor management, and appointment scheduling
3. `diagtool`: diagnostic scan intake, AI analysis orchestration, and FHIR diagnostic report creation
4. `inventory_management`: pharmacy stock, batches, prescriptions, billing, alerts, and analytics

The frontend is a Next.js App Router application with separate doctor, patient, admin, and inventory experiences.

In practice, the normal runtime is the unified FastAPI app in `backend/ehr/app/main.py`. That app mounts the EHR, scheduling, diagnostics, and inventory routers under `/api/v1`.

## 3. High-Level Architecture

### 3.1 Main runtime

The primary entrypoint is `backend/ehr/app/main.py`.

It mounts:

- EHR routers under `/api/v1/...`
- doctor management under `/api/v1/doctors/...`
- scheduler routes under `/api/v1/...`
- inventory routes under `/api/v1/inventory/...`
- diagnostics under `/api/v1/analyze`
- admin routes under `/api/v1/admin/...`

It also starts APScheduler on startup and runs nightly inventory jobs.

### 3.2 Standalone service entrypoints

These still exist and matter for KT because they partly overlap with the unified app:

| Entrypoint | Purpose | Notes |
| --- | --- | --- |
| `backend/ehr/app/main.py` | Unified app | Main deployment path for the full platform |
| `backend/reg_and_sched/app/api_main.py` | Standalone scheduling API | Contains cancellation endpoint that is not mounted in the unified scheduler router |
| `backend/diagtool/main.py` | Standalone diagnostics service | Exposes `/health` and mounts diagnostics at `/api/analyze` |
| `backend/inventory_management/app/main.py` | Standalone inventory API | Inventory can run alone under `/api/v1` |

### 3.3 Data ownership

| System | Used by | Role |
| --- | --- | --- |
| Google Cloud FHIR store | `ehr`, `reg_and_sched`, `diagtool` | Clinical source of truth for patients, encounters, observations, medication requests, conditions, and diagnostic reports |
| Google Cloud DICOM store | `diagtool`, `ehr` media proxy | Stores uploaded scan/report media |
| Google Cloud Storage | `ehr` | Signed/proxied access to files when needed |
| Supabase | `ehr`, `reg_and_sched` | Operational tables such as doctors, patients mirror, appointments, and doctor-patient connections |
| Firestore / Firebase | `ehr` chat | Conversation title/history storage for doctor and patient AI chat |
| PostgreSQL via SQLAlchemy | `inventory_management` | Inventory domain source of truth |
| Google Calendar API | `reg_and_sched` | Doctor availability and appointment event creation |
| Make.com webhook | `diagtool`, `ehr` chat | External AI automation trigger layer |
| Gemini / OpenFDA / Google CSE | `inventory_management` | OCR, product enrichment, and fuzzy medication matching |
| Zustand + localStorage | frontend | Session state and UI workflow state |

### 3.4 Frontend-to-backend shape

The frontend uses `frontend/src/lib/python-api.ts` as the main HTTP client layer:

- `pythonApi` -> `http://127.0.0.1:8000/api/v1`
- `pythonApiFormData` -> same base for multipart uploads
- `pythonInventoryApi` -> `/api/v1/inventory`
- `patientApi` in `frontend/src/lib/patient-api.ts` also points to `/api/v1`

So the frontend is written against the unified API, not the standalone backend services.

## 4. End-to-End Business Flows

### 4.1 Patient registration and appointment booking

Flow:

1. Patient login page calls `/api/v1/patients/check`
2. If patient does not exist, register via `/api/v1/patients/register`
3. Registration logic in `reg_and_sched` creates the patient in FHIR and mirrors it into Supabase
4. Patient browses slots with `/api/v1/slots/?date=...&doctor_id=...`
5. Booking calls `/api/v1/appointments/book`
6. Scheduler creates the appointment in Supabase, creates a FHIR Encounter, creates a Google Calendar event, and links doctor/patient in `doctor_patient_connections`

Key code path:

- API: `reg_and_sched/app/api/scheduler_routes.py`
- orchestration: `reg_and_sched/app/registration.py`, `patient_sync_service.py`, `scheduling.py`
- persistence: `reg_and_sched/app/services.py`

### 4.2 Diagnostics upload and report lifecycle

Flow:

1. Admin diagnostics page uploads scan/report files to `/api/v1/analyze`
2. `diagtool` converts files to DICOM and uploads them into the Healthcare DICOM store
3. Files and metadata are sent to the automation webhook
4. AI output text is parsed into a structured model
5. A FHIR `DiagnosticReport` is created and saved
6. Doctors later fetch pending reports, review them, and finalize them
7. Media access is served through `/api/v1/media/{token}`

Key code path:

- API: `diagtool/app/api/router.py`
- DICOM: `diagtool/app/services/dicom_service.py`
- AI trigger: `diagtool/app/services/automation_service.py`
- FHIR mapping: `diagtool/app/utils/fhir_mapper.py`
- review/fetch: `ehr/app/api/routes/reports.py`, `ehr/app/services/report_service.py`

### 4.3 Doctor AI assistant flow

Flow:

1. Doctor logs in and session is persisted in `useDoctorStore`
2. Research context fetches connected patients from `/api/v1/connections/patients/{doctor_id}`
3. Selected patient reports are fetched from `/api/v1/reports/patients/{patient_id}/reports`
4. Chat titles/history are fetched from `/api/v1/chat/titles` and `/api/v1/chat/messages/{conversation_id}`
5. Doctor sends a message to `/api/v1/chat/doctor`
6. Backend proxies to the research webhook and stores history in Firestore

### 4.4 Patient portal flow

Flow:

1. Main patient auth page is `/patient-login`
2. It checks patient existence, uses a mock OTP value, then logs in through `usePatientStore`
3. Patient dashboard and health records read summary/report/appointment data from unified APIs
4. Patient AI assistant uses `/api/v1/chat/patient` and `/api/v1/chat/titles?type=patient`

Important note:

`frontend/src/app/(patient)/patient-portal/login/page.tsx` is a separate localStorage-based demo-style flow and is not aligned with the primary patient login/register flow.

### 4.5 Inventory sale flow

Flow:

1. Inventory login authenticates via `/api/v1/inventory/auth/login`
2. Search and product details come from `/products`, `/products/{id}`, `/products/{id}/batches`
3. Prescription image matching uses `/prescriptions/match`
4. A preview sale call creates a FEFO dispense plan without committing stock
5. Confirm sale performs the stock mutation and persists sale, items, totals, and alerts
6. Stock jobs generate low-stock/expiry alerts nightly or manually

## 5. Backend Technical KT

### 5.1 Unified shell: `backend/ehr/app/main.py`

Responsibilities:

- creates the shared FastAPI app
- mounts all domain routers
- configures CORS
- starts APScheduler on startup
- exposes manual stock prediction trigger

Main functions:

- `read_root`
- `scheduled_job_wrapper`
- `start_scheduler`
- `trigger_stock_prediction_job`

### 5.2 EHR domain: `backend/ehr`

#### API and route layer

| File | Responsibility | Main functions / classes |
| --- | --- | --- |
| `app/api/deps.py` | dependency constructors | `get_fhir_service`, `get_patient_sync_manager` |
| `app/api/routes/patients.py` | patient create, get, search | `create_patient`, `get_patient`, `search_patients` |
| `app/api/routes/encounters.py` | encounter CRUD/search and doctor notes | `DoctorNoteInput`, `DoctorNoteCreate`, `create_encounter`, `get_encounter`, `search_encounters`, `add_doctor_note`, `get_encounter_notes` |
| `app/api/routes/observations.py` | quick vital creation and observation search | `EasyVitalInput`, `create_easy_observation`, `search_observations` |
| `app/api/routes/medication_requests.py` | medication request create/search | `create_medication_request`, `search_medication_requests` |
| `app/api/routes/conditions.py` | condition create/search | `create_condition`, `search_conditions` |
| `app/api/routes/terminology.py` | terminology lookups for vitals, LOINC, encounter classes, ICD10 | `VitalDefinition`, `BloodPressureDefinition`, `LOINCSearchResult`, `ActCodeSearchResult`, `TerminologySearchResult`, `get_supported_vitals`, `search_loinc_codes`, `search_encounter_class_codes`, `search_icd10_codes` |
| `app/api/routes/summary.py` | patient summary bundle shaping | `extract_resources_from_bundle`, `get_patient_summary` |
| `app/api/routes/reports.py` | patient report listing, single report fetch, report finalization, pending reviews | `get_fhir_service`, `get_report_service`, `ReportUpdate`, `PendingReview`, `list_reports_for_patient`, `get_single_report_details`, `finalize_report`, `get_doctor_pending_reviews` |
| `app/api/routes/chat.py` | Firestore-backed patient/doctor chat proxy | `get_firestore_db`, `ConversationSummary`, `ChatMessage`, `PatientChatInput`, `get_patient_email`, `get_conversation_titles`, `get_chat_history`, `patient_chat_proxy`, `doctor_chat_proxy` |
| `app/api/routes/connections.py` | doctor-patient relationship requests and lookup | `request_connection`, `get_doctors_for_patient`, `get_patients_for_doctor`, `update_connection_status`, `delete_connection`, `check_connection`, `get_doctors_connected_patients` |
| `app/api/routes/admin.py` | admin dashboards over patients/users/reports/schedule | `get_admin_stats`, `get_all_patients`, `get_all_users`, `get_all_reports`, `get_global_schedule` |
| `app/api/routes/media_router.py` | tokenized media proxy for diagnostic files | `get_media_file` |
| `app/api/routes/documents.py` | currently unused | fully commented out / not active |

#### Service layer

| File | Responsibility | Main functions / classes |
| --- | --- | --- |
| `app/services/fhir_service.py` | generic async FHIR client wrapper | `FHIRService`, `_get_auth_headers`, `get_resource`, `create_resource`, `delete_resource`, `search_resource`, `search_patient_by_demographics`, `update_resource` |
| `app/services/gcp_clients.py` | GCP credential loader | `get_gcp_credentials` |
| `app/services/gcs_service.py` | signed URL generation | `GCSService`, `get_signed_url_for_path` |
| `app/services/supabase_service.py` | Supabase client constructor | `get_supabase_client` |
| `app/services/report_service.py` | diagnostic report list/detail shaping | `ReportService`, `list_patient_reports`, `get_report_details` |

#### Models and utilities

The Pydantic model layer under `app/models/pydantic/` defines request/response contracts for:

- patients
- encounters
- observations
- medication requests
- conditions
- document references
- reports
- patient summaries
- doctor-patient connections

Utilities:

- `app/utils/parser.py` cleans HTML-like LLM output and parses it into structured response models

### 5.3 Scheduling and registration domain: `backend/reg_and_sched`

| File | Responsibility | Main functions / classes |
| --- | --- | --- |
| `app/api/doctors.py` | doctor login, create, search, Google OAuth connect/disconnect, token monitoring | `DoctorCreate`, `DoctorResponse`, `LoginRequest`, `login_doctor`, `send_welcome_email`, `create_doctor`, `search_doctors`, `start_google_auth`, `google_auth_callback`, `disconnect_google`, `monitor_doctor_connections`, `get_doctor_by_id` |
| `app/api/scheduler_routes.py` | unified app scheduler endpoints | `PatientCheckRequest`, `PatientCheckResponse`, `PatientRegisterRequest`, `AppointmentBookRequest`, `check_patient_existence`, `register_new_patient`, `get_slots_for_day`, `book_appointment`, `get_doctor_schedule`, `update_status`, `get_patient_schedule` |
| `app/api_main.py` | standalone scheduler app | `read_root`, `check_patient_existence`, `register_new_patient`, `get_slots_for_day`, `book_appointment`, `cancel_existing_appointment`, `update_status`, `get_doctor_schedule` |
| `app/doctor_manager.py` | doctor OAuth URL generation and callback handling | `DoctorManager`, `get_auth_url`, `handle_auth_callback`, `disconnect_doctor` |
| `app/patient_sync_service.py` | patient create-and-sync orchestration across FHIR and Supabase | `PatientSyncManager`, `_check_uniqueness`, `create_and_sync_patient`, `get_or_create_supabase_mirror` |
| `app/registration.py` | patient-facing registration manager | `PatientManager`, `new_registration`, `get_patient_by_phone_number`, `delete_patient` |
| `app/scheduling.py` | booking, slot generation, and cancellation logic | `ClinicScheduler`, `_trigger_reauth_email`, `get_available_slots`, `book_appointment`, `cancel_appointment` |
| `app/services.py` | Supabase DB access, Google Calendar access, SMTP notification, singleton constructors | `DatabaseService`, `CalendarService`, `NotificationService`, `get_db_service`, `get_calendar_service`, `get_notification_service` |
| `main1.py` | older utility/demo entry | `setup_logging`; not aligned with current constructor dependencies |

Operational behavior:

- `PatientSyncManager` is the bridge from registration into both FHIR and Supabase
- `ClinicScheduler` is the core orchestration class for appointments
- `DatabaseService` stores doctors, patients, appointments, and tokens in Supabase
- `CalendarService` owns Google OAuth flow construction and doctor-specific calendar service creation

### 5.4 Diagnostics domain: `backend/diagtool`

| File | Responsibility | Main functions / classes |
| --- | --- | --- |
| `main.py` | standalone diagnostics app | `health_check` |
| `app/api/router.py` | upload scans, trigger AI, create FHIR report | `analyze_scan_and_create_report` |
| `app/core/config.py` | diagnostics settings | `Settings`, `Settings.Config` |
| `app/models/diagnostic.py` | request/result models | `InitialScanData`, `LlmAnalysisResult`, `AnalysisCompleteData`, `InitiateAnalysisData` |
| `app/services/automation_service.py` | Make.com trigger-and-wait | `trigger_and_wait_for_analysis` |
| `app/services/dicom_service.py` | file to DICOM conversion, upload, retrieval | `DicomService`, `_get_auth_headers`, `convert_and_upload_instance`, `retrieve_instance_data`, `_create_dicom_dataset`, `_encapsulate_pdf`, `_store_raw_image`, `get_dicom_service` |
| `app/services/fhir_service.py` | diagnostics FHIR create client | `FhirServerSaveException`, `FHIRService`, `_get_auth_headers`, `create_resource` |
| `app/services/gcp_clients.py` | credentials and Healthcare API client creation | `get_gcp_credentials`, `get_healthcare_service_client` |
| `app/services/report_service.py` | patient report listing/detail support | `ReportService`, `list_patient_reports`, `get_report_details` |
| `app/utils/fhir_mapper.py` | convert AI output into FHIR `DiagnosticReport` | `map_ai_to_fhir_diagnostic_report` |
| `app/utils/parser.py` | parse LLM text and extract IDs/media | `extract_patient_id`, `extract_media_ids`, `parse_llm_text_to_model` |

### 5.5 Inventory domain: `backend/inventory_management`

#### API and jobs

| File | Responsibility | Main functions / classes |
| --- | --- | --- |
| `inventory_router.py` | adapter router for unified app mount | `inventory_router` wrapper only |
| `app/main.py` | standalone inventory app and scheduler | `scheduled_job_wrapper`, `start_scheduler`, `trigger_stock_prediction_job`, `read_root` |
| `app/api/v1/endpoints/auth.py` | pharmacist and admin login | `login_pharmacist`, `AdminLogin`, `login_admin` |
| `app/api/v1/endpoints/products.py` | create/search/fetch/enrich products | `create_product_endpoint`, `search_products_endpoint`, `get_product_endpoint`, `get_product_batches_endpoint`, `enrich_product_endpoint` |
| `app/api/v1/endpoints/batches.py` | batch create/get | `create_batch_endpoint`, `get_batch_endpoint` |
| `app/api/v1/endpoints/sales.py` | sale preview, create, listing | `preview_sale`, `create_sale`, `list_sales_endpoint` |
| `app/api/v1/endpoints/prescriptions.py` | image OCR and inventory match | `match_prescription_to_inventory` |
| `app/api/v1/endpoints/analytics.py` | summary, top sellers, slow movers, trends | `get_summary_endpoint`, `TopSellerSortBy`, `get_top_sellers_endpoint`, `get_slow_movers_endpoint`, `get_sales_trends_endpoint` |
| `app/api/v1/endpoints/alerts.py` | unread alerts and mark-read | `get_unread_alerts_endpoint`, `mark_alert_read_endpoint` |
| `app/api/v1/endpoints/suppliers.py` | supplier create/search | `create_supplier_endpoint`, `search_suppliers_endpoint` |
| `app/jobs/expiry_tracker.py` | expiry and near-expiry alert generation | `run_expiry_tracking_job` |
| `app/jobs/stock_predictor.py` | predictive stock analysis and low-stock alert generation | `run_stock_prediction_job` |

#### CRUD, services, schemas, models

| Layer | Files | Role |
| --- | --- | --- |
| CRUD | `crud_alert.py`, `crud_analytics.py`, `crud_batch.py`, `crud_medicine_info.py`, `crud_product.py`, `crud_sale.py`, `crud_supplier.py` | direct SQLAlchemy data access and transaction logic |
| Services | `ai_service.py`, `enrichment_service.py`, `sale_service.py` | OCR/AI extraction, external enrichment, FEFO dispense planning |
| DB | `db/session.py`, `db/base.py` | SQLAlchemy session and base wiring |
| Models | `models/models.py` | SQLAlchemy entities for products, batches, sales, sale_items, suppliers, customers, alerts, medicine_info, pharmacists, admins |
| Schemas | `schemas/*.py` | Pydantic contracts for products, batches, sales, suppliers, prescriptions, analytics, alerts, pharmacist auth |
| Utilities | `utils/exceptions.py` | domain-specific error types |

Key inventory behavior:

- stock is decremented transactionally at sale confirmation time
- preview uses FEFO allocation without mutating DB
- OCR extraction is separate from final dispense logic
- enrichment falls through local cache -> OpenFDA -> Google search/scrape

### 5.6 Other backend files

| File | Role |
| --- | --- |
| `backend/reset_reports.py` | async utility to reset all diagnostic reports to `preliminary` |
| `backend/ehr/test_creds.py` | credential smoke test |
| `backend/ehr/tests/test_patients.py` | currently empty |
| `backend/EXTERNAL_SERVICES_AND_APIS.md` | service dependency reference |
| existing `techdoc.md` files | older partial documentation per backend domain; useful context but not a complete current-source KT |

## 6. Frontend Technical KT

### 6.1 Frontend architecture

The frontend is a Next.js 16 App Router app under `frontend/src/app`.

Main state and integration patterns:

- Zustand for auth and workflow state
- Axios for backend communication
- React Query provider exists, but many pages still use manual `useState` + `useEffect`
- route-group layouts act as auth guards for role-specific areas

### 6.2 Route groups and page responsibilities

| Route | Component file | Purpose | Main dependencies |
| --- | --- | --- | --- |
| `/` | `src/app/page.tsx` | landing page | local UI only |
| `/provider-select` | `src/app/provider-select/page.tsx` | provider / role selection landing | navigation only |
| `/login` | `src/app/(auth)/login/page.tsx` | doctor login | `useDoctorStore`, unified API |
| `/admin-login` | `src/app/(auth)/admin-login/page.tsx` | admin login | `useAdminStore`, unified API |
| `/inventory-login` | `src/app/(auth)/inventory-login/page.tsx` | pharmacist/inventory login | currently uses doctor-style session store for auth guard |
| `/patient-login` | `src/app/(auth)/patient-login/page.tsx` | primary patient login flow | `usePatientStore`, `/patients/check`, mock OTP, unified API |
| `/patient-register` | `src/app/(auth)/patient-register/page.tsx` | primary patient registration flow | `usePatientStore`, `/patients/register` |
| `/hospital/doctor/doctor-dashboard` | `src/app/(dashboard)/hospital/doctor/doctor-dashboard/page.tsx` | doctor home dashboard | `useDoctorStore`, appointments/report/status APIs |
| `/hospital/doctor/appointments` | `src/app/(dashboard)/hospital/doctor/appointments/page.tsx` | doctor appointment management | `/appointments/doctor/{id}`, status update |
| `/hospital/doctor/ehr` | `src/app/(dashboard)/hospital/doctor/ehr/page.tsx` | doctor clinical record view | summary + report APIs |
| `/hospital/doctor/ai-assistant` | `src/app/(dashboard)/hospital/doctor/ai-assistant/page.tsx` | doctor AI research/chat UI | `ResearchProvider`, chat + connections + reports APIs |
| `/patient-portal` | `src/app/(patient)/patient-portal/page.tsx` | patient dashboard | patient summary/report APIs |
| `/patient-portal/appointments` | `src/app/(patient)/patient-portal/appointments/page.tsx` | patient self-service appointment booking | `/doctors/search`, `/slots`, `/appointments/book`, patient schedule |
| `/patient-portal/health-records` | `src/app/(patient)/patient-portal/health-records/page.tsx` | health records/report viewing | summary + reports |
| `/patient-portal/ai-assistant` | `src/app/(patient)/patient-portal/ai-assistant/page.tsx` | patient AI assistant | patient chat routes |
| `/patient-portal/profile` | `src/app/(patient)/patient-portal/profile/page.tsx` | patient profile | patient store + API |
| `/patient-portal/registration` | `src/app/(patient)/patient-portal/registration/page.tsx` | local multi-step registration UI | local state only |
| `/patient-portal/login` | `src/app/(patient)/patient-portal/login/page.tsx` | secondary demo-style login flow | localStorage only, not aligned with primary auth |
| `/admin-dashboard` | `src/app/(admin)/admin-dashboard/page.tsx` | admin metrics overview | `/admin/stats`, `/reports/all`, `/appointments/all` |
| `/admin-dashboard/ehr` | `src/app/(admin)/admin-dashboard/ehr/page.tsx` | patient registry view | `/admin/patients/all`, search |
| `/admin-dashboard/appointments` | `src/app/(admin)/admin-dashboard/appointments/page.tsx` | global appointment schedule | `/admin/appointments/all` |
| `/admin-dashboard/inventory` | `src/app/(admin)/admin-dashboard/inventory/page.tsx` | inventory dashboard container | inventory components |
| `/admin-dashboard/diagnostics` | `src/app/(admin)/admin-dashboard/diagnostics/page.tsx` | diagnostic upload + report oversight | `/analyze`, `/admin/reports/all`, patient search |
| `/inventory/sales` | `src/app/inventory/sales/page.tsx` | active sale workflow | sales session store, prescription upload, cart flow |
| `/inventory/stock` | `src/app/inventory/stock/page.tsx` | stock/batches/analytics/sales log | inventory service APIs |

### 6.3 Layouts and guards

| File | Role |
| --- | --- |
| `src/app/layout.tsx` | global app shell |
| `src/app/(auth)/layout.tsx` | auth-shell layout |
| `src/app/(auth)/(admin)/layout.tsx` | admin-auth sublayout |
| `src/app/(dashboard)/layout.tsx` | doctor auth gate via `useDoctorStore`; imports sidebar from inventory path even though it is used as doctor sidebar |
| `src/app/(patient)/layout.tsx` | patient auth gate via `usePatientStore` |
| `src/app/(admin)/layout.tsx` | admin auth gate via `useAdminStore` |
| `src/app/inventory/layout.tsx` | inventory auth gate; currently relies on doctor-style persisted auth pattern |

### 6.4 Shared state and API helpers

| File | Responsibility |
| --- | --- |
| `src/store/doctorStore.ts` | persisted doctor session: id, name, email, specialization, designation |
| `src/store/patientStore.ts` | persisted patient session: id, name, phone |
| `src/store/adminStore.ts` | persisted admin session |
| `src/store/sales-session.store.ts` | multi-session sales carts, active view, quantity updates, product replacement |
| `src/store/product-management.store.ts` | product and batch modal state |
| `src/store/useChatStore.ts` | currently empty placeholder |
| `src/lib/python-api.ts` | shared Axios clients for unified API and inventory subpath |
| `src/lib/patient-api.ts` | slim Axios client for patient flows |
| `src/lib/inventory-service.ts` | typed inventory API wrapper and numeric normalization |
| `src/lib/csv-export.ts` | CSV export utility |
| `src/lib/api-client.ts` | currently empty placeholder |
| `src/lib/providers.tsx` | currently empty placeholder |
| `src/lib/server/auth.ts` | currently empty placeholder |
| `src/lib/server/services/supabase.ts` | currently empty placeholder |
| `src/lib/server/services/make-ai.ts` | currently empty placeholder |
| `src/lib/server/services/gcp-fhir.ts` | currently empty placeholder |
| `src/context/research-context.tsx` | doctor AI assistant session orchestration |
| `src/hooks/usePatientData.ts` | currently empty placeholder |

### 6.5 Component groups

| Folder | Role |
| --- | --- |
| `src/components/doctor/` | doctor sidebar, header, tabs, report review modal |
| `src/components/ai-assistant/` | doctor AI chat side panel, report selector, patient selector, message bubble |
| `src/components/patient/` | patient portal header, sidebar, cards, chat sidebar |
| `src/components/admin/` | admin actions modal for doctor onboarding and linking |
| `src/components/inventory/shared/` | cart, sale summary, alert panel, session view, upload/review modals, navbar |
| `src/components/inventory/stock/` | analytics, product management, batch dialogs, sales log, supplier search |
| `src/components/ui/`, `src/components/doctor-ui/`, `src/components/inventory/ui/` | shared and domain-styled UI primitives |

## 7. Route and Dependency Notes Worth Calling Out

### 7.1 Unified backend route naming quirks

- reports are mounted under `/api/v1/reports`, but route handlers inside `reports.py` also contain `reports/...` and `patients/.../reports`
- as a result, the live paths are:
  - `/api/v1/reports/patients/{patient_id}/reports`
  - `/api/v1/reports/reports/{report_id}`
  - `/api/v1/reports/reports/{report_id}/finalize`

### 7.2 Standalone vs unified scheduler mismatch

- standalone scheduler app has `DELETE /appointments/{appointment_id}` for cancellation
- unified mounted scheduler router does not expose cancellation
- unified mounted scheduler router does expose patient schedule lookup
- standalone scheduler app does not expose patient schedule lookup

So route parity is incomplete between the two runtime shapes.

## 8. Current-State Gaps and Risks

1. `frontend/src/app/(auth)/patient-register/page.tsx` registers and logs in the patient, but then redirects back to `/patient-register` instead of a portal page.
2. `frontend/src/app/(patient)/patient-portal/login/page.tsx` is a separate demo-style auth flow using `localStorage`; it is not the same as the main patient auth flow under `/patient-login`.
3. `frontend/src/app/(dashboard)/layout.tsx` imports the sidebar from `@/components/inventory/shared/AppSidebar`; it works, but the naming is misleading because it is acting as the doctor sidebar.
4. `frontend/src/components/inventory/shared/PrescriptionReviewModal.tsx` is structurally incomplete in its table rendering; matched inventory and quantity cells are missing from the rendered row structure.
5. `backend/reg_and_sched/app/services.py` contains DB-like patient methods inside `NotificationService`. They reference `self.client`, which that class does not define, so those methods are effectively dead or misplaced.
6. `backend/reg_and_sched/main1.py` looks like an older demo/bootstrap file and no longer matches current dependency construction.
7. several frontend files are present as placeholders and currently empty: `useChatStore.ts`, `usePatientData.ts`, `api-client.ts`, `providers.tsx`, and the server service files under `src/lib/server/services/`
8. `backend/ehr/app/api/routes/documents.py` exists but is not active
9. `frontend/src/components/inventory/stock/SalesLog.tsx` has an export handler placeholder while `csv-export.ts` already exists
10. inventory alerts include backend-generated `BATCH_DEPLETED`, but the frontend alert-title/icon mapping is focused on low stock and expiry cases


## 11. Quick File Starting Points

If you want the fastest code-entry path after KT:

- backend assembly: `backend/ehr/app/main.py`
- EHR service wrapper: `backend/ehr/app/services/fhir_service.py`
- scheduler orchestration: `backend/reg_and_sched/app/scheduling.py`
- patient sync: `backend/reg_and_sched/app/patient_sync_service.py`
- diagnostics upload path: `backend/diagtool/app/api/router.py`
- inventory transaction logic: `backend/inventory_management/app/crud/crud_sale.py`
- frontend API base: `frontend/src/lib/python-api.ts`
- doctor AI state: `frontend/src/context/research-context.tsx`
- inventory UI workflow state: `frontend/src/store/sales-session.store.ts`

## 12. Appendix

The full route and function inventory is in [TECHNICAL_KT_APPENDIX.md](TECHNICAL_KT_APPENDIX.md).
