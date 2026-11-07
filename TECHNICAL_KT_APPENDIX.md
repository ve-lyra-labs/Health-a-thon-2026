# Technical KT Appendix

## 1. How To Use This Appendix

This appendix is the exhaustive lookup companion to `TECHNICAL_KT.md`.

Use it when you need:

- the exact live route path
- the file that owns a route
- the named functions and classes defined per file
- a quick way to answer "where is this implemented?"

## 2. Backend Route Catalog

### 2.1 Unified runtime routes from `backend/ehr/app/main.py`

These are the effective routes when the unified FastAPI app is running.

| Method | Full path | Handler | Source file |
| --- | --- | --- | --- |
| `GET` | `/` | `read_root` | `backend/ehr/app/main.py` |
| `POST` | `/api/v1/analyze` | `analyze_scan_and_create_report` | `backend/diagtool/app/api/router.py` |
| `POST` | `/api/v1/patients/` | `create_patient` | `backend/ehr/app/api/routes/patients.py` |
| `GET` | `/api/v1/patients/` | `search_patients` | `backend/ehr/app/api/routes/patients.py` |
| `GET` | `/api/v1/patients/{patient_id}` | `get_patient` | `backend/ehr/app/api/routes/patients.py` |
| `POST` | `/api/v1/encounters/` | `create_encounter` | `backend/ehr/app/api/routes/encounters.py` |
| `GET` | `/api/v1/encounters/` | `search_encounters` | `backend/ehr/app/api/routes/encounters.py` |
| `GET` | `/api/v1/encounters/{encounter_id}` | `get_encounter` | `backend/ehr/app/api/routes/encounters.py` |
| `POST` | `/api/v1/encounters/{encounter_id}/notes` | `add_doctor_note` | `backend/ehr/app/api/routes/encounters.py` |
| `GET` | `/api/v1/encounters/{encounter_id}/notes` | `get_encounter_notes` | `backend/ehr/app/api/routes/encounters.py` |
| `POST` | `/api/v1/observations/easy` | `create_easy_observation` | `backend/ehr/app/api/routes/observations.py` |
| `GET` | `/api/v1/observations/` | `search_observations` | `backend/ehr/app/api/routes/observations.py` |
| `POST` | `/api/v1/conditions/` | `create_condition` | `backend/ehr/app/api/routes/conditions.py` |
| `GET` | `/api/v1/conditions/` | `search_conditions` | `backend/ehr/app/api/routes/conditions.py` |
| `POST` | `/api/v1/medication-requests/` | `create_medication_request` | `backend/ehr/app/api/routes/medication_requests.py` |
| `GET` | `/api/v1/medication-requests/` | `search_medication_requests` | `backend/ehr/app/api/routes/medication_requests.py` |
| `GET` | `/api/v1/terminology/vitals` | `get_supported_vitals` | `backend/ehr/app/api/routes/terminology.py` |
| `GET` | `/api/v1/terminology/search` | `search_loinc_codes` | `backend/ehr/app/api/routes/terminology.py` |
| `GET` | `/api/v1/terminology/encounter-classes/search` | `search_encounter_class_codes` | `backend/ehr/app/api/routes/terminology.py` |
| `GET` | `/api/v1/terminology/conditions/search` | `search_icd10_codes` | `backend/ehr/app/api/routes/terminology.py` |
| `GET` | `/api/v1/summary/patient/{patient_id}` | `get_patient_summary` | `backend/ehr/app/api/routes/summary.py` |
| `GET` | `/api/v1/reports/patients/{patient_id}/reports` | `list_reports_for_patient` | `backend/ehr/app/api/routes/reports.py` |
| `GET` | `/api/v1/reports/reports/{report_id}` | `get_single_report_details` | `backend/ehr/app/api/routes/reports.py` |
| `PUT` | `/api/v1/reports/reports/{report_id}/finalize` | `finalize_report` | `backend/ehr/app/api/routes/reports.py` |
| `GET` | `/api/v1/reports/doctor/{doctor_id}/pending` | `get_doctor_pending_reviews` | `backend/ehr/app/api/routes/reports.py` |
| `GET` | `/api/v1/chat/titles` | `get_conversation_titles` | `backend/ehr/app/api/routes/chat.py` |
| `GET` | `/api/v1/chat/messages/{conversation_id}` | `get_chat_history` | `backend/ehr/app/api/routes/chat.py` |
| `POST` | `/api/v1/chat/patient` | `patient_chat_proxy` | `backend/ehr/app/api/routes/chat.py` |
| `POST` | `/api/v1/chat/doctor` | `doctor_chat_proxy` | `backend/ehr/app/api/routes/chat.py` |
| `POST` | `/api/v1/connections/request` | `request_connection` | `backend/ehr/app/api/routes/connections.py` |
| `GET` | `/api/v1/connections/doctors/{patient_id}` | `get_doctors_for_patient` | `backend/ehr/app/api/routes/connections.py` |
| `GET` | `/api/v1/connections/patients/{doctor_id}` | `get_patients_for_doctor` | `backend/ehr/app/api/routes/connections.py` |
| `PUT` | `/api/v1/connections/{connection_id}` | `update_connection_status` | `backend/ehr/app/api/routes/connections.py` |
| `DELETE` | `/api/v1/connections/{connection_id}` | `delete_connection` | `backend/ehr/app/api/routes/connections.py` |
| `GET` | `/api/v1/connections/check/{doctor_id}/{patient_id}` | `check_connection` | `backend/ehr/app/api/routes/connections.py` |
| `GET` | `/api/v1/connections/doctors/{doctor_id}/patients` | `get_doctors_connected_patients` | `backend/ehr/app/api/routes/connections.py` |
| `GET` | `/api/v1/media/{token:path}` | `get_media_file` | `backend/ehr/app/api/routes/media_router.py` |
| `GET` | `/api/v1/admin/stats` | `get_admin_stats` | `backend/ehr/app/api/routes/admin.py` |
| `GET` | `/api/v1/admin/patients/all` | `get_all_patients` | `backend/ehr/app/api/routes/admin.py` |
| `GET` | `/api/v1/admin/users/all` | `get_all_users` | `backend/ehr/app/api/routes/admin.py` |
| `GET` | `/api/v1/admin/reports/all` | `get_all_reports` | `backend/ehr/app/api/routes/admin.py` |
| `GET` | `/api/v1/admin/appointments/all` | `get_global_schedule` | `backend/ehr/app/api/routes/admin.py` |
| `POST` | `/api/v1/doctors/login` | `login_doctor` | `backend/reg_and_sched/app/api/doctors.py` |
| `POST` | `/api/v1/doctors/` | `create_doctor` | `backend/reg_and_sched/app/api/doctors.py` |
| `GET` | `/api/v1/doctors/search` | `search_doctors` | `backend/reg_and_sched/app/api/doctors.py` |
| `GET` | `/api/v1/doctors/{doctor_id}/auth/url` | `start_google_auth` | `backend/reg_and_sched/app/api/doctors.py` |
| `GET` | `/api/v1/doctors/auth/callback` | `google_auth_callback` | `backend/reg_and_sched/app/api/doctors.py` |
| `DELETE` | `/api/v1/doctors/{doctor_id}/auth` | `disconnect_google` | `backend/reg_and_sched/app/api/doctors.py` |
| `POST` | `/api/v1/doctors/monitor-connections` | `monitor_doctor_connections` | `backend/reg_and_sched/app/api/doctors.py` |
| `GET` | `/api/v1/doctors/{doctor_id}` | `get_doctor_by_id` | `backend/reg_and_sched/app/api/doctors.py` |
| `POST` | `/api/v1/patients/check` | `check_patient_existence` | `backend/reg_and_sched/app/api/scheduler_routes.py` |
| `POST` | `/api/v1/patients/register` | `register_new_patient` | `backend/reg_and_sched/app/api/scheduler_routes.py` |
| `GET` | `/api/v1/slots/` | `get_slots_for_day` | `backend/reg_and_sched/app/api/scheduler_routes.py` |
| `POST` | `/api/v1/appointments/book` | `book_appointment` | `backend/reg_and_sched/app/api/scheduler_routes.py` |
| `GET` | `/api/v1/appointments/doctor/{doctor_id}` | `get_doctor_schedule` | `backend/reg_and_sched/app/api/scheduler_routes.py` |
| `PATCH` | `/api/v1/appointments/{appointment_id}/status` | `update_status` | `backend/reg_and_sched/app/api/scheduler_routes.py` |
| `GET` | `/api/v1/appointments/patient/{patient_id}` | `get_patient_schedule` | `backend/reg_and_sched/app/api/scheduler_routes.py` |
| `GET` | `/api/v1/inventory/alerts/` | `get_unread_alerts_endpoint` | `backend/inventory_management/app/api/v1/endpoints/alerts.py` |
| `POST` | `/api/v1/inventory/alerts/{alert_id}/read` | `mark_alert_read_endpoint` | `backend/inventory_management/app/api/v1/endpoints/alerts.py` |
| `GET` | `/api/v1/inventory/analytics/summary` | `get_summary_endpoint` | `backend/inventory_management/app/api/v1/endpoints/analytics.py` |
| `GET` | `/api/v1/inventory/analytics/top-sellers` | `get_top_sellers_endpoint` | `backend/inventory_management/app/api/v1/endpoints/analytics.py` |
| `GET` | `/api/v1/inventory/analytics/slow-movers` | `get_slow_movers_endpoint` | `backend/inventory_management/app/api/v1/endpoints/analytics.py` |
| `GET` | `/api/v1/inventory/analytics/sales-trends` | `get_sales_trends_endpoint` | `backend/inventory_management/app/api/v1/endpoints/analytics.py` |
| `POST` | `/api/v1/inventory/auth/login` | `login_pharmacist` | `backend/inventory_management/app/api/v1/endpoints/auth.py` |
| `POST` | `/api/v1/inventory/auth/admin/login` | `login_admin` | `backend/inventory_management/app/api/v1/endpoints/auth.py` |
| `POST` | `/api/v1/inventory/batches/` | `create_batch_endpoint` | `backend/inventory_management/app/api/v1/endpoints/batches.py` |
| `GET` | `/api/v1/inventory/batches/{batch_id}` | `get_batch_endpoint` | `backend/inventory_management/app/api/v1/endpoints/batches.py` |
| `POST` | `/api/v1/inventory/prescriptions/match` | `match_prescription_to_inventory` | `backend/inventory_management/app/api/v1/endpoints/prescriptions.py` |
| `POST` | `/api/v1/inventory/products/` | `create_product_endpoint` | `backend/inventory_management/app/api/v1/endpoints/products.py` |
| `GET` | `/api/v1/inventory/products/` | `search_products_endpoint` | `backend/inventory_management/app/api/v1/endpoints/products.py` |
| `GET` | `/api/v1/inventory/products/{product_id}` | `get_product_endpoint` | `backend/inventory_management/app/api/v1/endpoints/products.py` |
| `GET` | `/api/v1/inventory/products/{product_id}/batches` | `get_product_batches_endpoint` | `backend/inventory_management/app/api/v1/endpoints/products.py` |
| `GET` | `/api/v1/inventory/products/enrich` | `enrich_product_endpoint` | `backend/inventory_management/app/api/v1/endpoints/products.py` |
| `POST` | `/api/v1/inventory/sales/preview` | `preview_sale` | `backend/inventory_management/app/api/v1/endpoints/sales.py` |
| `POST` | `/api/v1/inventory/sales/` | `create_sale` | `backend/inventory_management/app/api/v1/endpoints/sales.py` |
| `GET` | `/api/v1/inventory/sales/` | `list_sales_endpoint` | `backend/inventory_management/app/api/v1/endpoints/sales.py` |
| `POST` | `/api/v1/inventory/suppliers/` | `create_supplier_endpoint` | `backend/inventory_management/app/api/v1/endpoints/suppliers.py` |
| `GET` | `/api/v1/inventory/suppliers/` | `search_suppliers_endpoint` | `backend/inventory_management/app/api/v1/endpoints/suppliers.py` |
| `POST` | `/api/v1/inventory/jobs/trigger-stock-prediction` | `trigger_stock_prediction_job` | `backend/ehr/app/main.py` |

### 2.2 Standalone and alternate entrypoint routes

These matter because they are real entrypoints in the repo even when the unified app is the usual runtime.

| Service | Method | Path | Handler | Note |
| --- | --- | --- | --- | --- |
| `backend/diagtool/main.py` | `GET` | `/health` | `health_check` | diagnostics health probe |
| `backend/diagtool/main.py` | `POST` | `/api/analyze` | `analyze_scan_and_create_report` | standalone diagnostics path |
| `backend/inventory_management/app/main.py` | `GET` | `/` | `read_root` | standalone inventory root |
| `backend/inventory_management/app/main.py` | `POST` | `/api/v1/jobs/trigger-stock-prediction` | `trigger_stock_prediction_job` | standalone inventory job trigger |
| `backend/reg_and_sched/app/api_main.py` | `GET` | `/` | `read_root` | standalone scheduler root |
| `backend/reg_and_sched/app/api_main.py` | `POST` | `/patients/check` | `check_patient_existence` | standalone scheduler |
| `backend/reg_and_sched/app/api_main.py` | `POST` | `/patients/register` | `register_new_patient` | standalone scheduler |
| `backend/reg_and_sched/app/api_main.py` | `GET` | `/slots/` | `get_slots_for_day` | standalone scheduler |
| `backend/reg_and_sched/app/api_main.py` | `POST` | `/appointments/book` | `book_appointment` | standalone scheduler |
| `backend/reg_and_sched/app/api_main.py` | `DELETE` | `/appointments/{appointment_id}` | `cancel_existing_appointment` | standalone-only cancellation route |
| `backend/reg_and_sched/app/api_main.py` | `PATCH` | `/appointments/{appointment_id}/status` | `update_status` | standalone scheduler |
| `backend/reg_and_sched/app/api_main.py` | `GET` | `/appointments/doctor/{doctor_id}` | `get_doctor_schedule` | standalone scheduler |
| `backend/reg_and_sched/app/api_main.py` | `POST` | `/api/v1/doctors/login` | `login_doctor` | doctor router mounted under `/api/v1/doctors` |
| `backend/reg_and_sched/app/api_main.py` | `POST` | `/api/v1/doctors/` | `create_doctor` | doctor router mounted under `/api/v1/doctors` |
| `backend/reg_and_sched/app/api_main.py` | `GET` | `/api/v1/doctors/search` | `search_doctors` | doctor router mounted under `/api/v1/doctors` |
| `backend/reg_and_sched/app/api_main.py` | `GET` | `/api/v1/doctors/{doctor_id}/auth/url` | `start_google_auth` | doctor router mounted under `/api/v1/doctors` |
| `backend/reg_and_sched/app/api_main.py` | `GET` | `/api/v1/doctors/auth/callback` | `google_auth_callback` | doctor router mounted under `/api/v1/doctors` |
| `backend/reg_and_sched/app/api_main.py` | `DELETE` | `/api/v1/doctors/{doctor_id}/auth` | `disconnect_google` | doctor router mounted under `/api/v1/doctors` |
| `backend/reg_and_sched/app/api_main.py` | `POST` | `/api/v1/doctors/monitor-connections` | `monitor_doctor_connections` | doctor router mounted under `/api/v1/doctors` |
| `backend/reg_and_sched/app/api_main.py` | `GET` | `/api/v1/doctors/{doctor_id}` | `get_doctor_by_id` | doctor router mounted under `/api/v1/doctors` |

## 3. Frontend Route/File Inventory

| Route or special file | Type | File |
| --- | --- | --- |
| `/` | `page.tsx` | `frontend/src/app/page.tsx` |
| `/provider-select` | `page.tsx` | `frontend/src/app/provider-select/page.tsx` |
| `/login` | `page.tsx` | `frontend/src/app/(auth)/login/page.tsx` |
| `/admin-login` | `page.tsx` | `frontend/src/app/(auth)/admin-login/page.tsx` |
| `/inventory-login` | `page.tsx` | `frontend/src/app/(auth)/inventory-login/page.tsx` |
| `/patient-login` | `page.tsx` | `frontend/src/app/(auth)/patient-login/page.tsx` |
| `/patient-register` | `page.tsx` | `frontend/src/app/(auth)/patient-register/page.tsx` |
| `(auth)` | `layout.tsx` | `frontend/src/app/(auth)/layout.tsx` |
| `(auth)/(admin)` | `layout.tsx` | `frontend/src/app/(auth)/(admin)/layout.tsx` |
| `/hospital/doctor/doctor-dashboard` | `page.tsx` | `frontend/src/app/(dashboard)/hospital/doctor/doctor-dashboard/page.tsx` |
| `/hospital/doctor/appointments` | `page.tsx` | `frontend/src/app/(dashboard)/hospital/doctor/appointments/page.tsx` |
| `/hospital/doctor/ehr` | `page.tsx` | `frontend/src/app/(dashboard)/hospital/doctor/ehr/page.tsx` |
| `/hospital/doctor/ai-assistant` | `page.tsx` | `frontend/src/app/(dashboard)/hospital/doctor/ai-assistant/page.tsx` |
| `(dashboard)` | `layout.tsx` | `frontend/src/app/(dashboard)/layout.tsx` |
| `(dashboard)` | `loading.tsx` | `frontend/src/app/(dashboard)/loading.tsx` |
| `/patient-portal` | `page.tsx` | `frontend/src/app/(patient)/patient-portal/page.tsx` |
| `/patient-portal/appointments` | `page.tsx` | `frontend/src/app/(patient)/patient-portal/appointments/page.tsx` |
| `/patient-portal/health-records` | `page.tsx` | `frontend/src/app/(patient)/patient-portal/health-records/page.tsx` |
| `/patient-portal/ai-assistant` | `page.tsx` | `frontend/src/app/(patient)/patient-portal/ai-assistant/page.tsx` |
| `/patient-portal/profile` | `page.tsx` | `frontend/src/app/(patient)/patient-portal/profile/page.tsx` |
| `/patient-portal/registration` | `page.tsx` | `frontend/src/app/(patient)/patient-portal/registration/page.tsx` |
| `/patient-portal/login` | `page.tsx` | `frontend/src/app/(patient)/patient-portal/login/page.tsx` |
| `(patient)` | `layout.tsx` | `frontend/src/app/(patient)/layout.tsx` |
| `/admin-dashboard` | `page.tsx` | `frontend/src/app/(admin)/admin-dashboard/page.tsx` |
| `/admin-dashboard/ehr` | `page.tsx` | `frontend/src/app/(admin)/admin-dashboard/ehr/page.tsx` |
| `/admin-dashboard/appointments` | `page.tsx` | `frontend/src/app/(admin)/admin-dashboard/appointments/page.tsx` |
| `/admin-dashboard/inventory` | `page.tsx` | `frontend/src/app/(admin)/admin-dashboard/inventory/page.tsx` |
| `/admin-dashboard/diagnostics` | `page.tsx` | `frontend/src/app/(admin)/admin-dashboard/diagnostics/page.tsx` |
| `(admin)` | `layout.tsx` | `frontend/src/app/(admin)/layout.tsx` |
| `/inventory/sales` | `page.tsx` | `frontend/src/app/inventory/sales/page.tsx` |
| `/inventory/stock` | `page.tsx` | `frontend/src/app/inventory/stock/page.tsx` |
| `/inventory` | `layout.tsx` | `frontend/src/app/inventory/layout.tsx` |
| `/api/v1/registration/new` | `route.ts` | `frontend/src/app/api/v1/registration/new/route.ts` |
| `/api/v1/patients/{patientId}` | `route.ts` | `frontend/src/app/api/v1/patients/[patientId]/route.ts` |
| `/api/v1/summary/patient/{patientId}` | `route.ts` | `frontend/src/app/api/v1/summary/patient/[patientId]/route.ts` |
| root app shell | `layout.tsx` | `frontend/src/app/layout.tsx` |

## 4. Backend Function and Class Inventory

### 4.1 `backend/diagtool`

## backend/diagtool/app/api/router.py
- L25: async def `analyze_scan_and_create_report`

## backend/diagtool/app/core/config.py
- L7: class `Settings`
- L43: class `Settings.Config`

## backend/diagtool/app/models/diagnostic.py
- L6: class `InitialScanData`
- L11: class `LlmAnalysisResult`
- L21: class `AnalysisCompleteData`
- L29: class `InitiateAnalysisData`

## backend/diagtool/app/services/automation_service.py
- L10: async def `trigger_and_wait_for_analysis`

## backend/diagtool/app/services/dicom_service.py
- L18: class `DicomService`
- L19: def `DicomService.__init__`
- L28: async def `DicomService._get_auth_headers`
- L34: async def `DicomService.convert_and_upload_instance`
- L63: async def `DicomService.retrieve_instance_data`
- L120: def `DicomService._create_dicom_dataset`
- L132: def `DicomService._encapsulate_pdf`
- L139: def `DicomService._store_raw_image`
- L158: def `get_dicom_service`

## backend/diagtool/app/services/fhir_service.py
- L10: class `FhirServerSaveException`
- L12: def `FhirServerSaveException.__init__`
- L17: class `FHIRService`
- L22: def `FHIRService.__init__`
- L28: async def `FHIRService._get_auth_headers`
- L34: async def `FHIRService.create_resource`

## backend/diagtool/app/services/gcp_clients.py
- L10: def `get_gcp_credentials`
- L39: def `get_healthcare_service_client`

## backend/diagtool/app/services/report_service.py
- L9: class `ReportService`
- L13: def `ReportService.__init__`
- L16: async def `ReportService.list_patient_reports`
- L34: async def `ReportService.get_report_details`

## backend/diagtool/app/utils/fhir_mapper.py
- L6: def `map_ai_to_fhir_diagnostic_report`

## backend/diagtool/app/utils/parser.py
- L8: def `extract_patient_id`
- L19: def `extract_media_ids`
- L31: def `parse_llm_text_to_model`

## backend/diagtool/main.py
- L15: def `health_check`

### 4.2 `backend/ehr`

## backend/ehr/app/__init__.py
- No classes or functions

## backend/ehr/app/api/__init__.py
- No classes or functions

## backend/ehr/app/api/deps.py
- L22: def `get_fhir_service`
- L33: def `get_patient_sync_manager`

## backend/ehr/app/api/routes/__init__.py
- No classes or functions

## backend/ehr/app/api/routes/admin.py
- L14: async def `get_admin_stats`
- L54: async def `get_all_patients`
- L70: async def `get_all_users`
- L96: async def `get_all_reports`
- L122: async def `get_global_schedule`

## backend/ehr/app/api/routes/chat.py
- L29: def `get_firestore_db`
- L69: class `ConversationSummary`
- L73: class `ChatMessage`
- L78: class `PatientChatInput`
- L86: def `get_patient_email`
- L99: async def `get_conversation_titles`
- L135: async def `get_chat_history`
- L181: async def `patient_chat_proxy`
- L210: async def `doctor_chat_proxy`

## backend/ehr/app/api/routes/conditions.py
- L13: async def `create_condition`
- L26: async def `search_conditions`

## backend/ehr/app/api/routes/connections.py
- L13: async def `request_connection`
- L60: async def `get_doctors_for_patient`
- L104: async def `get_patients_for_doctor`
- L169: async def `update_connection_status`
- L198: async def `delete_connection`
- L226: async def `check_connection`
- L251: async def `get_doctors_connected_patients`

## backend/ehr/app/api/routes/documents.py
- No classes or functions

## backend/ehr/app/api/routes/encounters.py
- L13: class `DoctorNoteInput`
- L19: async def `create_encounter`
- L33: async def `get_encounter`
- L48: async def `search_encounters`
- L60: class `DoctorNoteCreate`
- L67: async def `add_doctor_note`
- L90: async def `get_encounter_notes`

## backend/ehr/app/api/routes/media_router.py
- L12: async def `get_media_file`

## backend/ehr/app/api/routes/medication_requests.py
- L13: async def `create_medication_request`
- L26: async def `search_medication_requests`

## backend/ehr/app/api/routes/observations.py
- L11: class `EasyVitalInput`
- L22: async def `create_easy_observation`
- L63: async def `search_observations`

## backend/ehr/app/api/routes/patients.py
- L15: async def `create_patient`
- L48: async def `get_patient`
- L66: async def `search_patients`

## backend/ehr/app/api/routes/reports.py
- L21: def `get_fhir_service`
- L25: def `get_report_service`
- L32: class `ReportUpdate`
- L43: class `PendingReview`
- L53: async def `list_reports_for_patient`
- L60: async def `get_single_report_details`
- L70: async def `finalize_report`
- L119: async def `get_doctor_pending_reviews`

## backend/ehr/app/api/routes/summary.py
- L13: def `extract_resources_from_bundle`
- L18: async def `get_patient_summary`

## backend/ehr/app/api/routes/terminology.py
- L14: class `VitalDefinition`
- L20: class `BloodPressureDefinition`
- L27: class `LOINCSearchResult`
- L31: class `ActCodeSearchResult`
- L36: class `TerminologySearchResult`
- L50: async def `get_supported_vitals`
- L56: async def `search_loinc_codes`
- L108: async def `search_encounter_class_codes`
- L143: async def `search_icd10_codes`

## backend/ehr/app/core/__init__.py
- No classes or functions

## backend/ehr/app/core/config.py
- L20: class `Settings`
- L65: class `Settings.Config`

## backend/ehr/app/main.py
- L45: async def `read_root`
- L82: def `scheduled_job_wrapper`
- L94: def `start_scheduler`
- L107: def `trigger_stock_prediction_job`

## backend/ehr/app/models/__init__.py
- No classes or functions

## backend/ehr/app/models/pydantic/__init__.py
- No classes or functions

## backend/ehr/app/models/pydantic/condition.py
- L7: class `ConditionCreate`
- L25: class `ConditionCreate.Config`

## backend/ehr/app/models/pydantic/connections.py
- L6: class `ConnectionStatus`
- L12: class `ConnectionRequest`
- L17: class `ConnectionUpdate`
- L20: class `ConnectionResponse`
- L28: class `PatientInfo`
- L34: class `DoctorInfo`
- L40: class `ConnectionWithPatient`
- L43: class `ConnectionWithDoctor`

## backend/ehr/app/models/pydantic/document_reference.py
- L7: class `Attachment`
- L12: class `Content`
- L16: class `DocumentReferenceContext`
- L19: class `DocumentReferenceCreate`

## backend/ehr/app/models/pydantic/encounter.py
- L6: class `Coding`
- L11: class `EncounterType`
- L14: class `Reference`
- L18: class `EncounterCreate`
- L31: class `EncounterCreate.Config`

## backend/ehr/app/models/pydantic/medication_request.py
- L7: class `DosageInstruction`
- L11: class `MedicationRequestCreate`
- L23: class `MedicationRequestCreate.Config`

## backend/ehr/app/models/pydantic/observation.py
- L8: class `Coding`
- L13: class `CodeableConcept`
- L16: class `ValueQuantity`
- L22: class `Reference`
- L27: class `ObservationComponent`
- L34: class `ObservationCreate`
- L52: class `ObservationCreate.Config`

## backend/ehr/app/models/pydantic/patient.py
- L6: class `HumanName`
- L11: class `PatientCreate`
- L26: class `PatientCreate.Config`

## backend/ehr/app/models/pydantic/report.py
- L7: class `ReportSummary`
- L14: class `StructuredAnalysis`
- L24: class `ReportDetail`
- L33: class `LlmAnalysisResult`

## backend/ehr/app/models/pydantic/summary.py
- L14: class `PatientSummary`

## backend/ehr/app/services/__init__.py
- No classes or functions

## backend/ehr/app/services/fhir_service.py
- L10: class `FHIRService`
- L17: def `FHIRService.__init__`
- L24: async def `FHIRService._get_auth_headers`
- L33: async def `FHIRService.get_resource`
- L45: async def `FHIRService.create_resource`
- L52: async def `FHIRService.delete_resource`
- L72: async def `FHIRService.search_resource`
- L80: async def `FHIRService.search_patient_by_demographics`
- L124: async def `FHIRService.update_resource`

## backend/ehr/app/services/gcp_clients.py
- L9: def `get_gcp_credentials`

## backend/ehr/app/services/gcs_service.py
- L7: class `GCSService`
- L8: def `GCSService.__init__`
- L16: def `GCSService.get_signed_url_for_path`

## backend/ehr/app/services/report_service.py
- L19: class `ReportService`
- L21: def `ReportService.__init__`
- L25: async def `ReportService.list_patient_reports`
- L49: async def `ReportService.get_report_details`

## backend/ehr/app/services/supabase_service.py
- L7: def `get_supabase_client`

## backend/ehr/app/utils/parser.py
- L5: def `_cleanup_metadata_from_text`
- L21: def `parse_html_div_to_model`

## backend/ehr/test_creds.py
- No classes or functions

## backend/ehr/tests/__init__.py
- Parse error: unexpected indent (<unknown>, line 1)

## backend/ehr/tests/test_patients.py
- No classes or functions

### 4.3 `backend/inventory_management`

## backend/inventory_management/app/__init__.py
- No classes or functions

## backend/inventory_management/app/api/__init__.py
- No classes or functions

## backend/inventory_management/app/api/v1/__init__.py
- No classes or functions

## backend/inventory_management/app/api/v1/api.py
- No classes or functions

## backend/inventory_management/app/api/v1/endpoints/__init__.py
- No classes or functions

## backend/inventory_management/app/api/v1/endpoints/alerts.py
- L17: def `get_unread_alerts_endpoint`
- L45: def `mark_alert_read_endpoint`

## backend/inventory_management/app/api/v1/endpoints/analytics.py
- L20: def `get_summary_endpoint`
- L33: class `TopSellerSortBy`
- L44: def `get_top_sellers_endpoint`
- L66: def `get_slow_movers_endpoint`
- L87: def `get_sales_trends_endpoint`

## backend/inventory_management/app/api/v1/endpoints/auth.py
- L11: def `login_pharmacist`
- L26: class `AdminLogin`
- L31: def `login_admin`

## backend/inventory_management/app/api/v1/endpoints/batches.py
- L20: def `create_batch_endpoint`
- L51: def `get_batch_endpoint`

## backend/inventory_management/app/api/v1/endpoints/prescriptions.py
- L28: async def `match_prescription_to_inventory`

## backend/inventory_management/app/api/v1/endpoints/products.py
- L24: async def `create_product_endpoint`
- L94: def `search_products_endpoint`
- L122: def `get_product_endpoint`
- L137: def `get_product_batches_endpoint`
- L155: async def `enrich_product_endpoint`

## backend/inventory_management/app/api/v1/endpoints/sales.py
- L29: def `preview_sale`
- L73: def `create_sale`
- L151: def `list_sales_endpoint`

## backend/inventory_management/app/api/v1/endpoints/suppliers.py
- L19: def `create_supplier_endpoint`
- L36: def `search_suppliers_endpoint`

## backend/inventory_management/app/core/__init__.py
- No classes or functions

## backend/inventory_management/app/core/config.py
- L7: class `Settings`
- L13: class `Settings.Config`
- L17: def `Settings.setup_logging`

## backend/inventory_management/app/crud/__init__.py
- No classes or functions

## backend/inventory_management/app/crud/crud_alert.py
- L8: def `create_alert`
- L16: def `get_unread_alert_for_product_by_type`
- L34: def `get_unread_low_stock_alert_for_product`
- L46: def `get_unread_alerts`
- L58: def `mark_alert_as_read`

## backend/inventory_management/app/crud/crud_analytics.py
- L11: def `get_sales_summary`
- L61: def `get_top_sellers`
- L125: def `get_slow_movers`
- L206: def `get_sales_trends`

## backend/inventory_management/app/crud/crud_batch.py
- L12: def `get_active_batches_for_product_fefo`
- L29: def `get_batch`
- L34: def `get_batch_by_number`
- L41: def `get_batches_for_product`
- L55: def `create_batch`

## backend/inventory_management/app/crud/crud_medicine_info.py
- L8: def `get_medicine_info_by_name`
- L19: def `create_or_update_medicine_info`

## backend/inventory_management/app/crud/crud_product.py
- L10: def `get_product`
- L15: def `get_product_by_name`
- L20: def `search_products`
- L49: def `create_product`

## backend/inventory_management/app/crud/crud_sale.py
- L14: def `create_sale_transaction`
- L88: def `get_sales`

## backend/inventory_management/app/crud/crud_supplier.py
- L9: def `get_supplier`
- L13: def `get_supplier_by_name`
- L17: def `search_suppliers`
- L28: def `create_supplier`

## backend/inventory_management/app/db/__init__.py
- No classes or functions

## backend/inventory_management/app/db/base.py
- No classes or functions

## backend/inventory_management/app/db/session.py
- L16: def `get_db`

## backend/inventory_management/app/jobs/expiry_tracker.py
- L12: def `run_expiry_tracking_job`

## backend/inventory_management/app/jobs/stock_predictor.py
- L14: def `run_stock_prediction_job`

## backend/inventory_management/app/main.py
- L34: def `scheduled_job_wrapper`
- L47: def `start_scheduler`
- L67: def `trigger_stock_prediction_job`
- L79: def `read_root`

## backend/inventory_management/app/models/__init__.py
- No classes or functions

## backend/inventory_management/app/models/base.py
- No classes or functions

## backend/inventory_management/app/models/models.py
- L14: class `BatchStatus`
- L24: class `Product`
- L39: class `Batch`
- L61: class `Sale`
- L78: class `SaleItem`
- L96: class `Supplier`
- L108: class `Customer`
- L118: class `Alert`
- L137: class `MedicineInfo`
- L147: class `Pharmacist`
- L157: class `Admin`

## backend/inventory_management/app/schemas/__init__.py
- No classes or functions

## backend/inventory_management/app/schemas/alert.py
- L7: class `Alert`

## backend/inventory_management/app/schemas/analytics.py
- L8: class `AnalyticsSummary`
- L17: class `ProductPerformance`
- L27: class `SalesTrendItem`
- L34: class `SlowMover`

## backend/inventory_management/app/schemas/batch.py
- L14: class `BatchBase`
- L29: class `BatchCreate`
- L35: class `BatchUpdate`
- L43: class `Batch`

## backend/inventory_management/app/schemas/medicine_info.py
- L6: class `MedicineInfoBase`
- L13: class `MedicineInfoCreate`
- L17: class `MedicineInfo`

## backend/inventory_management/app/schemas/pharmacist.py
- L4: class `PharmacistLogin`
- L8: class `PharmacistResponse`
- L13: class `PharmacistResponse.Config`

## backend/inventory_management/app/schemas/prescription.py
- L10: class `ExtractedMedicine`
- L19: class `AvailableBatchInfo`
- L27: class `AIPrescriptionResponse`
- L33: class `MatchedItem`
- L57: class `PrescriptionMatchResponse`

## backend/inventory_management/app/schemas/product.py
- L10: class `ProductCreateMagic`
- L21: class `ProductBase`
- L33: class `ProductCreate`
- L38: class `ProductUpdate`
- L49: class `Product`
- L56: class `ProductWithBatches`

## backend/inventory_management/app/schemas/sale.py
- L12: class `SaleCartItem`
- L18: class `SalePreviewRequest`
- L23: class `DispensePlanItem`
- L31: class `SalePreviewItemResponse`
- L39: class `SalePreviewResponse`
- L48: class `SaleCreate`
- L58: class `SaleItem`
- L67: class `Sale`
- L78: class `SaleListItem`
- L88: class `SaleList`
- L99: class `PaginatedSalesResponse`
- L107: class `ReceiptItem`
- L115: class `Receipt`

## backend/inventory_management/app/schemas/supplier.py
- L6: class `SupplierBase`
- L15: class `SupplierCreate`
- L19: class `Supplier`

## backend/inventory_management/app/services/__init__.py
- No classes or functions

## backend/inventory_management/app/services/ai_service.py
- L7: def `configure_genai`
- L14: def `extract_medicines_from_image`

## backend/inventory_management/app/services/enrichment_service.py
- L15: class `EnrichedData`
- L18: def `EnrichedData.__init__`
- L24: def `EnrichedData.to_schema`
- L33: async def `_query_openfda`
- L72: async def `_query_google_and_scrape`
- L174: async def `get_enriched_details`

## backend/inventory_management/app/services/sale_service.py
- L12: def `generate_dispense_plan`

## backend/inventory_management/app/utils/__init__.py
- No classes or functions

## backend/inventory_management/app/utils/exceptions.py
- L5: class `AppException`
- L8: def `AppException.__init__`
- L13: class `InsufficientStockError`
- L18: def `InsufficientStockError.__init__`

## backend/inventory_management/inventory_router.py
- No classes or functions

### 4.4 `backend/reg_and_sched`

## backend/reg_and_sched/__init__.py
- No classes or functions

## backend/reg_and_sched/app/api/doctors.py
- L24: class `DoctorCreate`
- L33: class `DoctorResponse`
- L43: class `LoginRequest`
- L49: def `login_doctor`
- L74: def `send_welcome_email`
- L107: def `create_doctor`
- L131: def `search_doctors`
- L144: def `start_google_auth`
- L153: def `google_auth_callback`
- L172: def `disconnect_google`
- L177: def `monitor_doctor_connections`
- L238: def `get_doctor_by_id`

## backend/reg_and_sched/app/api/scheduler_routes.py
- L28: class `PatientCheckRequest`
- L31: class `PatientCheckResponse`
- L35: class `PatientRegisterRequest`
- L43: class `AppointmentBookRequest`
- L52: def `check_patient_existence`
- L59: async def `register_new_patient`
- L73: def `get_slots_for_day`
- L80: async def `book_appointment`
- L92: def `get_doctor_schedule`
- L97: def `update_status`
- L104: def `get_patient_schedule`

## backend/reg_and_sched/app/api_main.py
- L59: class `PatientCheckRequest`
- L62: class `PatientCheckResponse`
- L66: class `PatientRegisterRequest`
- L74: class `AppointmentBookRequest`
- L87: def `read_root`
- L91: def `check_patient_existence`
- L102: async def `register_new_patient`
- L125: def `get_slots_for_day`
- L136: async def `book_appointment`
- L156: async def `cancel_existing_appointment`
- L164: def `update_status`
- L176: def `get_doctor_schedule`

## backend/reg_and_sched/app/doctor_manager.py
- L6: class `DoctorManager`
- L7: def `DoctorManager.__init__`
- L11: def `DoctorManager.get_auth_url`
- L27: def `DoctorManager.handle_auth_callback`
- L53: def `DoctorManager.disconnect_doctor`

## backend/reg_and_sched/app/patient_sync_service.py
- L17: class `PatientSyncManager`
- L22: def `PatientSyncManager.__init__`
- L27: async def `PatientSyncManager._check_uniqueness`
- L45: async def `PatientSyncManager.create_and_sync_patient`
- L123: async def `PatientSyncManager.get_or_create_supabase_mirror`

## backend/reg_and_sched/app/registration.py
- L13: class `PatientManager`
- L25: def `PatientManager.__init__`
- L41: async def `PatientManager.new_registration`
- L92: def `PatientManager.get_patient_by_phone_number`
- L100: async def `PatientManager.delete_patient`

## backend/reg_and_sched/app/scheduling.py
- L14: class `ClinicScheduler`
- L15: def `ClinicScheduler.__init__`
- L29: def `ClinicScheduler._trigger_reauth_email`
- L79: def `ClinicScheduler.get_available_slots`
- L119: async def `ClinicScheduler.book_appointment`
- L235: async def `ClinicScheduler.cancel_appointment`

## backend/reg_and_sched/app/services.py
- L24: class `DatabaseService`
- L25: def `DatabaseService.__init__`
- L51: def `DatabaseService.create_appointment`
- L71: def `DatabaseService.get_appointment`
- L80: def `DatabaseService.delete_appointment`
- L91: def `DatabaseService.create_patient`
- L108: def `DatabaseService.get_patient_by_phone`
- L117: def `DatabaseService.delete_patient_by_phone`
- L127: def `DatabaseService.get_appointments_for_patient_on_date`
- L148: def `DatabaseService.create_doctor`
- L159: def `DatabaseService.search_doctors`
- L185: def `DatabaseService.get_doctor_tokens`
- L195: def `DatabaseService.update_doctor_tokens`
- L212: def `DatabaseService.update_appointment_status`
- L221: def `DatabaseService.get_doctor_appointments`
- L262: def `DatabaseService.get_patient_appointments`
- L292: class `CalendarService`
- L293: def `CalendarService.__init__`
- L300: def `CalendarService._get_client_config`
- L305: def `CalendarService.get_oauth_flow`
- L315: def `CalendarService.get_service_for_doctor`
- L350: def `CalendarService.get_events`
- L360: def `CalendarService.create_event`
- L369: def `CalendarService.delete_event`
- L376: class `NotificationService`
- L378: def `NotificationService.__init__`
- L383: def `NotificationService.send_email`
- L399: def `NotificationService.create_patient`
- L412: def `NotificationService.get_patient_by_phone`
- L422: def `NotificationService.delete_patient_by_phone`
- L439: def `get_db_service`
- L444: def `get_calendar_service`
- L449: def `get_notification_service`

## backend/reg_and_sched/main1.py
- L7: def `setup_logging`

## backend/reset_reports.py
- L39: async def `reset_all_reports_to_preliminary`

## 5. Frontend Function Inventory

## frontend/src/app/(admin)/admin-dashboard/appointments/page.tsx
- L18: export default function `GlobalSchedule`
- L33: const arrow `fetchData`
- L59: const arrow `handlePreset`

## frontend/src/app/(admin)/admin-dashboard/diagnostics/page.tsx
- L12: export default function `DiagnosticsPage`
- L37: const arrow `fetchGlobalReports`
- L45: const arrow `searchPatients`
- L58: const arrow `selectSearchResult`
- L64: const arrow `handleUpload`

## frontend/src/app/(admin)/admin-dashboard/ehr/page.tsx
- L16: const arrow `unwrapBundle`
- L18: export default function `MasterRegistry`
- L33: const arrow `fetchData`
- L45: const arrow `handleOpenPatient`

## frontend/src/app/(admin)/admin-dashboard/inventory/page.tsx
- L5: export default function `AdminInventory`

## frontend/src/app/(admin)/admin-dashboard/page.tsx
- L16: export default function `AdminDashboard`
- L27: const arrow `loadData`
- L226: function `MetricCard`

## frontend/src/app/(admin)/layout.tsx
- L10: export default function `AdminLayout`

## frontend/src/app/(auth)/(admin)/layout.tsx
- L10: export default function `AdminLayout`

## frontend/src/app/(auth)/admin-login/page.tsx
- L12: export default function `AdminLoginPage`
- L21: const arrow `handleLogin`

## frontend/src/app/(auth)/inventory-login/page.tsx
- L12: export default function `InventoryLoginPage`
- L21: const arrow `handleLogin`

## frontend/src/app/(auth)/layout.tsx
- L1: export default function `AuthLayout`

## frontend/src/app/(auth)/login/page.tsx
- L12: export default function `LoginPage`
- L21: const arrow `handleLogin`

## frontend/src/app/(auth)/patient-login/page.tsx
- L13: export default function `PatientLogin`
- L22: const arrow `handleCheckPhone`
- L48: const arrow `handleVerifyOtp`

## frontend/src/app/(auth)/patient-register/page.tsx
- L13: export default function `PatientRegister`
- L35: const arrow `handleRegister`

## frontend/src/app/(dashboard)/hospital/doctor/ai-assistant/page.tsx
- L17: const arrow `formatAIResponse`
- L35: function `ChatInterface`
- L59: const arrow `handleLoadChat`
- L76: const arrow `handleNewChat`
- L84: const arrow `handleSend`
- L136: const arrow `handleResearchToggle`
- L144: const arrow `handleFileChange`
- L151: const arrow `removeFile`
- L279: export default function `AIAssistantPage`

## frontend/src/app/(dashboard)/hospital/doctor/appointments/page.tsx
- L22: export default function `DoctorAppointmentsPage`
- L29: const arrow `fetchAppointments`
- L47: const arrow `handleStatusUpdate`

## frontend/src/app/(dashboard)/hospital/doctor/doctor-dashboard/page.tsx
- L33: export default function `DashboardPage`
- L87: const arrow `handleStatusUpdate`

## frontend/src/app/(dashboard)/hospital/doctor/ehr/page.tsx
- L27: const arrow `getStatusStyles`
- L32: const arrow `unwrapBundle`
- L37: const arrow `getVitalValue`
- L56: export default function `DoctorEHRPage`
- L113: const arrow `handleOpenModal`

## frontend/src/app/(dashboard)/layout.tsx
- L10: export default function `DashboardLayout`

## frontend/src/app/(dashboard)/loading.tsx
- L3: export default function `Loading`

## frontend/src/app/(patient)/layout.tsx
- L10: export default function `PatientLayout`

## frontend/src/app/(patient)/patient-portal/ai-assistant/page.tsx
- L23: export default function `AIAssistant`
- L59: const arrow `fetchHistory`
- L73: const arrow `loadChat`
- L88: const arrow `handleNewChat`
- L95: const arrow `handleSend`

## frontend/src/app/(patient)/patient-portal/appointments/page.tsx
- L30: const arrow `Card`
- L34: const arrow `getStatusColor`
- L44: export default function `AppointmentsPage`
- L65: const arrow `initData`
- L82: const arrow `fetchMyAppointments`
- L98: const arrow `fetchSlots`
- L115: const arrow `handleBook`
- L138: const arrow `handleReset`

## frontend/src/app/(patient)/patient-portal/health-records/page.tsx
- L13: const arrow `getVitalValue`
- L29: const arrow `unwrapBundle`
- L34: export default function `HealthRecords`
- L51: const arrow `fetchData`
- L83: const arrow `handleViewReport`

## frontend/src/app/(patient)/patient-portal/login/page.tsx
- L12: export default function `PatientLogin`
- L36: const arrow `handlePhoneSubmit`
- L48: const arrow `handleOtpVerify`
- L57: const arrow `handleRegistration`
- L74: const arrow `handleOtpChange`
- L83: const arrow `openCalendar`

## frontend/src/app/(patient)/patient-portal/page.tsx
- L13: const arrow `getVital`
- L33: export default function `PatientDashboard`
- L48: const arrow `fetchData`
- L89: const arrow `handleViewReport`

## frontend/src/app/(patient)/patient-portal/profile/page.tsx
- L18: export default function `Profile`
- L26: const arrow `fetchProfile`

## frontend/src/app/(patient)/patient-portal/registration/page.tsx
- L5: export default function `Registration`
- L10: const arrow `handleNext`
- L15: const arrow `handlePrev`
- L20: const arrow `openCalendar`

## frontend/src/app/api/v1/patients/[patientId]/route.ts
- No top-level or inner named functions matched

## frontend/src/app/api/v1/registration/new/route.ts
- No top-level or inner named functions matched

## frontend/src/app/api/v1/summary/patient/[patientId]/route.ts
- No top-level or inner named functions matched

## frontend/src/app/inventory/layout.tsx
- L11: export default function `InventoryLayout`

## frontend/src/app/inventory/sales/page.tsx
- L13: function `WelcomeScreen`
- L18: const arrow `handlePrescriptionSuccess`
- L71: export default function `HomePage`

## frontend/src/app/inventory/stock/page.tsx
- L8: export default function `StockManagementPage`

## frontend/src/app/layout.tsx
- L21: export default function `RootLayout`

## frontend/src/app/page.tsx
- L6: export default function `GrandEntrance`

## frontend/src/app/provider-select/page.tsx
- L6: export default function `PortalLanding`

## frontend/src/components/QueryProvider.tsx
- L6: export default function `QueryProvider`

## frontend/src/components/admin/AdminActionsModal.tsx
- L13: export function `AdminActionsModal`
- L38: const arrow `handleLink`
- L50: const arrow `handleAddDoctor`

## frontend/src/components/ai-assistant/ChatSidebar.tsx
- L23: const arrow `handleGlobalLogout`

## frontend/src/components/ai-assistant/MessageBubble.tsx
- No top-level or inner named functions matched

## frontend/src/components/ai-assistant/PatientSelector.tsx
- No top-level or inner named functions matched

## frontend/src/components/ai-assistant/ReportSelector.tsx
- No top-level or inner named functions matched

## frontend/src/components/doctor/AppSidebar.tsx
- L24: export function `AppSidebar`
- L29: const arrow `handleLogout`

## frontend/src/components/doctor/DoctorHeader.tsx
- L8: export default function `DoctorHeader`
- L12: const arrow `handleLogout`

## frontend/src/components/doctor/DoctorTabs.tsx
- L8: export default function `DoctorTabs`

## frontend/src/components/doctor/ReportReviewModal.tsx
- L31: export function `ReportReviewModal`
- L73: const arrow `handleSave`
- L87: const arrow `updateField`
- L92: const arrow `updateFinding`

## frontend/src/components/doctor-ui/badge.tsx
- L8: export function `Badge`

## frontend/src/components/doctor-ui/button.tsx
- No top-level or inner named functions matched

## frontend/src/components/doctor-ui/calendar.tsx
- L12: function `Calendar`
- L54: const arrow `goPrev`
- L55: const arrow `goNext`

## frontend/src/components/doctor-ui/dialog.tsx
- No top-level or inner named functions matched

## frontend/src/components/doctor-ui/dropdown-menu.tsx
- No top-level or inner named functions matched

## frontend/src/components/doctor-ui/input.tsx
- No top-level or inner named functions matched

## frontend/src/components/doctor-ui/table.tsx
- No top-level or inner named functions matched

## frontend/src/components/doctor-ui/tabs.tsx
- No top-level or inner named functions matched

## frontend/src/components/inventory/InventoryHeader.tsx
- L12: export default function `InventoryHeader`
- L22: const arrow `handleLogout`

## frontend/src/components/inventory/receipt/ReceiptModal.tsx
- L14: export function `ReceiptModal`
- L17: const arrow `handlePrint`

## frontend/src/components/inventory/shared/ActiveSessionView.tsx
- L9: export function `ActiveSessionView`

## frontend/src/components/inventory/shared/AlertsPanel.tsx
- L11: const arrow `getAlertIcon`
- L22: const arrow `getAlertTitle`
- L38: export function `AlertsPanel`

## frontend/src/components/inventory/shared/AlertsTrigger.tsx
- L12: export function `AlertsTrigger`

## frontend/src/components/inventory/shared/AppSidebar.tsx
- L24: export function `AppSidebar`
- L29: const arrow `handleLogout`

## frontend/src/components/inventory/shared/Cart.tsx
- L14: export function `Cart`
- L31: const arrow `handleInputChange`
- L35: const arrow `handleInputBlur`

## frontend/src/components/inventory/shared/DataTable.tsx
- L36: export function `DataTable`

## frontend/src/components/inventory/shared/ErrorBoundary.tsx
- No top-level or inner named functions matched

## frontend/src/components/inventory/shared/PrescriptionReviewModal.tsx
- L24: export function `PrescriptionReviewModal`
- L36: const arrow `handleQuantityChange`
- L45: const arrow `handleReplaceProduct`
- L69: const arrow `handleAddToCart`

## frontend/src/components/inventory/shared/PrescriptionUpload.tsx
- L15: export function `PrescriptionUpload`
- L24: const arrow `handleFileChange`
- L34: const arrow `handleCardClick`

## frontend/src/components/inventory/shared/SalePreviewModal.tsx
- L17: export function `SalePreviewModal`

## frontend/src/components/inventory/shared/SaleSummary.tsx
- L17: export function `SaleSummary`
- L56: const arrow `handlePreview`
- L68: const arrow `handleConfirm`
- L77: const arrow `handleNewSale`
- L86: const arrow `handleDiscountChange`

## frontend/src/components/inventory/shared/TopNavbar.tsx
- L11: export function `TopNavbar`
- L22: const arrow `handleCloseSession`

## frontend/src/components/inventory/stock/AnalyticsDashboard.tsx
- L11: export function `AnalyticsDashboard`

## frontend/src/components/inventory/stock/BatchDetailsSubComponent.tsx
- L8: export function `BatchDetailsSubComponent`

## frontend/src/components/inventory/stock/BatchList.tsx
- L11: export function `BatchList`

## frontend/src/components/inventory/stock/CreateBatchDialog.tsx
- L36: export function `CreateBatchDialog`
- L69: const arrow `onSubmit`

## frontend/src/components/inventory/stock/CreateProductDialog.tsx
- L27: export function `CreateProductDialog`
- L62: const arrow `onSubmit`

## frontend/src/components/inventory/stock/ProductManagement.tsx
- L80: export function `ProductManagement`

## frontend/src/components/inventory/stock/ProductSearch.tsx
- L19: export function `ProductSearch`
- L72: const arrow `handleSelectProduct`

## frontend/src/components/inventory/stock/SalesLog.tsx
- L30: export function `SalesLog`
- L45: const arrow `setDatePreset`
- L58: const arrow `handleExport`

## frontend/src/components/inventory/stock/SupplierSearch.tsx
- L17: export function `SupplierSearch`
- L29: const arrow `handleSelect`

## frontend/src/components/inventory/ui/alert.tsx
- No top-level or inner named functions matched

## frontend/src/components/inventory/ui/card.tsx
- No top-level or inner named functions matched

## frontend/src/components/inventory/ui/command.tsx
- No top-level or inner named functions matched

## frontend/src/components/inventory/ui/dialog.tsx
- No top-level or inner named functions matched

## frontend/src/components/inventory/ui/form.tsx
- No top-level or inner named functions matched

## frontend/src/components/inventory/ui/label.tsx
- No top-level or inner named functions matched

## frontend/src/components/inventory/ui/popover.tsx
- No top-level or inner named functions matched

## frontend/src/components/inventory/ui/table.tsx
- No top-level or inner named functions matched

## frontend/src/components/inventory/ui/tabs.tsx
- No top-level or inner named functions matched

## frontend/src/components/inventory/ui/tooltip.tsx
- No top-level or inner named functions matched

## frontend/src/components/patient/Header.tsx
- L7: export default function `Header`

## frontend/src/components/patient/PatientChatSidebar.tsx
- No top-level or inner named functions matched

## frontend/src/components/patient/RecentReportCard.tsx
- L14: const arrow `getStatusColor`

## frontend/src/components/patient/Sidebar.tsx
- L16: export default function `Sidebar`
- L21: const arrow `handleLogout`

## frontend/src/components/patient/StatsCard.tsx
- No top-level or inner named functions matched

## frontend/src/components/ui/alert.tsx
- No top-level or inner named functions matched

## frontend/src/components/ui/button.tsx
- No top-level or inner named functions matched

## frontend/src/components/ui/card.tsx
- No top-level or inner named functions matched

## frontend/src/components/ui/command.tsx
- L26: const arrow `CommandDialog`

## frontend/src/components/ui/dialog.tsx
- No top-level or inner named functions matched

## frontend/src/components/ui/dropdown-menu.tsx
- No top-level or inner named functions matched

## frontend/src/components/ui/form.tsx
- L42: const arrow `useFormField`

## frontend/src/components/ui/input.tsx
- No top-level or inner named functions matched

## frontend/src/components/ui/label.tsx
- No top-level or inner named functions matched

## frontend/src/components/ui/popover.tsx
- No top-level or inner named functions matched

## frontend/src/components/ui/select.tsx
- No top-level or inner named functions matched

## frontend/src/components/ui/table.tsx
- No top-level or inner named functions matched

## frontend/src/components/ui/tabs.tsx
- No top-level or inner named functions matched

## frontend/src/components/ui/tooltip.tsx
- No top-level or inner named functions matched

## frontend/src/context/research-context.tsx
- L37: export function `ResearchProvider`
- L61: const arrow `initData`
- L95: const arrow `refreshChatHistory`
- L113: const arrow `fetchReports`
- L132: const arrow `selectPatient`
- L141: const arrow `toggleReport`
- L147: const arrow `toggleResearchMode`
- L154: const arrow `confirmNewResearch`
- L159: const arrow `clearSession`

## frontend/src/hooks/usePatientData.ts
- No top-level or inner named functions matched

## frontend/src/lib/api-client.ts
- No top-level or inner named functions matched

## frontend/src/lib/csv-export.ts
- L4: export function `exportToCsv`

## frontend/src/lib/inventory-service.ts
- No top-level or inner named functions matched

## frontend/src/lib/patient-api.ts
- No top-level or inner named functions matched

## frontend/src/lib/providers.tsx
- No top-level or inner named functions matched

## frontend/src/lib/python-api.ts
- No top-level or inner named functions matched

## frontend/src/lib/server/auth.ts
- No top-level or inner named functions matched

## frontend/src/lib/server/services/gcp-fhir.ts
- No top-level or inner named functions matched

## frontend/src/lib/server/services/make-ai.ts
- No top-level or inner named functions matched

## frontend/src/lib/server/services/supabase.ts
- No top-level or inner named functions matched

## frontend/src/lib/utils.ts
- L4: export function `cn`

## frontend/src/store/adminStore.ts
- No top-level or inner named functions matched

## frontend/src/store/doctorStore.ts
- No top-level or inner named functions matched

## frontend/src/store/patientStore.ts
- No top-level or inner named functions matched

## frontend/src/store/product-management.store.ts
- No top-level or inner named functions matched

## frontend/src/store/sales-session.store.ts
- No top-level or inner named functions matched

## frontend/src/store/useChatStore.ts
- No top-level or inner named functions matched

## frontend/src/types/ai.types.ts
- No top-level or inner named functions matched

## frontend/src/types/api.ts
- No top-level or inner named functions matched

## frontend/src/types/index.ts
- No top-level or inner named functions matched

## frontend/src/types/inventory/alert.ts
- No top-level or inner named functions matched

## frontend/src/types/inventory/analytics.ts
- No top-level or inner named functions matched

## frontend/src/types/inventory/batch.ts
- No top-level or inner named functions matched

## frontend/src/types/inventory/prescription.ts
- No top-level or inner named functions matched

## frontend/src/types/inventory/product.ts
- No top-level or inner named functions matched

## frontend/src/types/inventory/sale.ts
- No top-level or inner named functions matched

## frontend/src/types/inventory/supplier.ts
- No top-level or inner named functions matched
