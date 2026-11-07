# Deployment Status

## What We're Doing
Making the Healthcare Suite deployment-ready on Azure Container Apps (ACA) using Terraform for infrastructure.

---

## Done

### Code Fixes
- [x] CORS — made configurable via `CORS_ORIGINS` env var (reads from Key Vault at startup)
- [x] `frontend/next.config.mjs` — added `output: "standalone"` for minimal Docker image
- [x] `pnpm-lock.yaml` — generated at repo root (pnpm workspace)

### Dockerfiles
- [x] `backend/Dockerfile` — Python 3.11-slim, installs requirements, runs `start_server.py`
- [x] `backend/.dockerignore` — excludes venv, credentials, .env, __pycache__
- [x] `frontend/Dockerfile` — Node 20-slim, multi-stage build (deps → builder → runner), accepts `NEXT_PUBLIC_API_URL` build arg. Fixed: copies both root + frontend node_modules from deps stage (pnpm workspace symlinks).
- [x] `.dockerignore` (repo root) — for frontend build context

### Terraform (terraform/)
- [x] `main.tf` — provider + remote state backend (lyratfstate storage account)
- [x] `variables.tf`
- [x] `data.tf` — data sources for existing RG + Key Vault (lyrah-keyvault)
- [x] `acr.tf` — Azure Container Registry (lyrahacr)
- [x] `identity.tf` — managed identities for backend + frontend, ACR pull roles, KV access policy
- [x] `log_analytics.tf` — Log Analytics Workspace
- [x] `container_apps.tf` — ACA Environment + backend app (1 replica) + frontend app (1-3 replicas)
- [x] `outputs.tf` — FQDNs, ACR login server
- [x] `terraform.tfvars` — subscription ID, RG, location, ACR name, backend image

### Azure Infrastructure (via terraform apply — all succeeded)
- [x] Managed Identity — id-lyra-backend
- [x] Managed Identity — id-lyra-frontend
- [x] Key Vault access policy — backend identity granted Get/List on lyrah-keyvault
- [x] Azure Container Registry — lyrahacr.azurecr.io
- [x] ACR pull role assignments — both identities
- [x] Log Analytics Workspace — log-lyra-healthcare
- [x] Container Apps Environment — cae-lyra-healthcare
- [x] Container App — ca-lyra-backend (real image, running)
- [x] Container App — ca-lyra-frontend (real image, running)

### Docker Images
- [x] Backend image built (linux/amd64) and pushed — `lyrahacr.azurecr.io/lyra-backend:latest`
- [x] Frontend image built (linux/amd64) and pushed — `lyrahacr.azurecr.io/lyra-frontend:latest`

### ADO Pipeline
- [x] `azure-pipelines.yml` written at repo root
  - Triggers on push to main
  - Builds backend + frontend with `--platform linux/amd64`
  - Tags images with both `latest` and `$(Build.BuildId)`
  - Deploys to both Container Apps via `az containerapp update`

### Key Info
- Backend FQDN: `https://ca-lyra-backend--b69f39o.mangodesert-2507e228.centralindia.azurecontainerapps.io`
- Frontend FQDN (stable): `https://ca-lyra-frontend.mangodesert-2507e228.centralindia.azurecontainerapps.io`
- ACR: `lyrahacr.azurecr.io`
- Subscription: `66fef50d-bbe2-40de-9777-85e1966a3ef5`
- Resource Group: `lyra-healthcare-rg`

---

## Deployment Complete ✅

Pipeline is live, both apps healthy, login + registration working end-to-end on
both the ACA URL and the custom domain `https://lyra-healthtech.com`.

- [x] ADO service connection `lyra-azure-sc` + pipeline created and running
- [x] Custom domain `lyra-healthtech.com` attached — A record → `98.70.217.203`,
      `asuid` TXT verification, managed cert bound (`SniEnabled`), HTTP→HTTPS redirect
- [x] All backend startup + auth issues resolved (see Gotchas below)

---

## Gotchas Hit During Deploy (read before redeploying)

These were the non-obvious failures, in the order we hit them:

1. **Backend crashed at startup — empty `DATABASE_URL`.** `session.py` calls
   `create_engine()` at import time, which ran before Key Vault loaded.
   **Fix:** `start_server.py` now calls `load_keyvault_secrets()` *before*
   importing the app. `DATABASE_URL` is also set directly as a Container App
   secret (`secretref:database-url`) as a belt-and-suspenders.

2. **Key Vault `ForbiddenByRbac`.** The vault uses **RBAC authorization**
   (`enableRbacAuthorization=true`), so the Terraform *access policy* did nothing.
   **Fix:** granted the backend managed identity (`70de47eb...`) the
   **Key Vault Secrets User** role on the vault. ✅ Now codified in
   `terraform/identity.tf` as `azurerm_role_assignment.backend_kv_secrets`
   (access policy removed) — see "Terraform is reconciled" below.

3. **Frontend `Cannot find module '/app/server.js'`.** In a pnpm workspace the
   Next.js standalone output nests under `frontend/`. **Fix:** Dockerfile CMD is
   `node frontend/server.js`, and `public/` + `.next/static` are copied to
   `./frontend/...` not `./`.

4. **Frontend had no styling / login did nothing.** The code reads
   `NEXT_PUBLIC_PYTHON_API_URL` but the pipeline passed `NEXT_PUBLIC_API_URL`, so
   it fell back to `http://127.0.0.1:8000`. **Fix:** pipeline + Dockerfile now use
   `NEXT_PUBLIC_PYTHON_API_URL=$(BACKEND_URL)/api/v1`. Also switched `BACKEND_URL`
   from a revision-specific FQDN to the stable app FQDN.

5. **FHIR/DICOM auth — `AADSTS7000232`.** Two identities collide: the **managed
   identity** (`70cf07ae`) is pinned to `AZURE_CLIENT_ID` for KV/ACR, but FHIR/DICOM
   need the **app registration** `lyrah-backend-app` (`d1e8e66e`), which holds
   *FHIR Data Contributor* + *DICOM Data Owner*. KV-loaded `AZURE_CLIENT_SECRET`
   made `DefaultAzureCredential` try to use the managed identity *with a secret*.
   **Fix:** FHIR/DICOM services use `ClientSecretCredential` reading dedicated
   `AZURE_FHIR_CLIENT_ID` / `AZURE_FHIR_CLIENT_SECRET` / `AZURE_FHIR_TENANT_ID`
   (KV secrets `AZURE-FHIR-*`), so they don't collide with `AZURE_CLIENT_ID`.

### Two-identity model (important)
| Identity | Client ID | Used for |
|---|---|---|
| Managed identity `id-lyra-backend` | `70cf07ae` (obj `70de47eb`) | Key Vault, ACR pull (`AZURE_CLIENT_ID`) |
| App registration `lyrah-backend-app` | `d1e8e66e` (obj `e407b23a`) | FHIR + DICOM (`AZURE_FHIR_*`) |

---

## Terraform is reconciled (apply is safe)

As of this deploy, `terraform/` matches live infra — `terraform plan` reports
**"No changes."** The manual `az` fixes have been codified:

- `identity.tf` — `azurerm_role_assignment.backend_kv_secrets`
  (**Key Vault Secrets User**) replaces the inert RBAC access policy.
- `container_apps.tf` — backend `secret {}` blocks pull `database-url`,
  `secret-key`, `jwt-algorithm`, `jwt-expire-minutes` from Key Vault **by
  reference** (versionless → rotation-aware), wired to env vars.
- Both apps have `lifecycle { ignore_changes = [template[0].container[0].image] }`
  so the **ADO pipeline owns the image tag** and Terraform never reverts it.

**Managed outside Terraform (intentionally — do not expect TF to manage these):**
- Custom domain `lyra-healthtech.com` + managed cert (provider treats the
  ingress custom_domain as computed; bound via `az containerapp hostname bind`).
- Key Vault *secret values* (`AZURE-FHIR-*`, `cors-origins`, etc.) — data, not infra.

**Two decoupled workflows going forward:**
| Want to change… | Do this | Triggers |
|---|---|---|
| App code / images | `git push origin main` | ADO pipeline builds + deploys |
| Infrastructure | `terraform apply` | Azure API only — **never** runs the pipeline |
| Add a new secret | `az keyvault secret set …` | `keyvault.py` auto-loads it at startup |

`terraform apply` and pipeline pushes do not conflict. If you add a new
Terraform resource that already exists in Azure, `terraform import` it first
(that's how the role assignment above was reconciled).

---

## Azure Resources Summary

| Resource | Name | RG |
|---|---|---|
| Container Registry | lyrahacr | lyra-healthcare-rg |
| Backend Identity | id-lyra-backend | lyra-healthcare-rg |
| Frontend Identity | id-lyra-frontend | lyra-healthcare-rg |
| Log Analytics | log-lyra-healthcare | lyra-healthcare-rg |
| ACA Environment | cae-lyra-healthcare | lyra-healthcare-rg |
| Backend App | ca-lyra-backend | lyra-healthcare-rg |
| Frontend App | ca-lyra-frontend | lyra-healthcare-rg |
| Key Vault | lyrah-keyvault | lyra-healthcare-rg (existing) |
| Postgres | lyrah-postgres | lyra-healthcare-rg (existing) |
| Terraform State | lyratfstate | rg-lyra-tfstate |
