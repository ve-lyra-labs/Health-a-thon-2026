# Deploying Changes

How to ship changes to the Healthcare Suite safely. Read this before your first push.
Full background and the list of issues already solved is in `DEPLOYMENT_STATUS.md`.

## TL;DR — shipping code

```bash
git checkout main
git pull origin main      # always start from latest — old branches reintroduce fixed bugs
# ... make your changes ...
git add . && git commit -m "your message"
git push origin main      # triggers the ADO pipeline automatically
```

Watch Azure DevOps → Pipelines. Green = deployed to both Container Apps.

## How deploy works

- **Trigger:** any push to `main` runs `azure-pipelines.yml` — builds backend +
  frontend images, pushes to ACR (`lyrahacr`), updates both Container Apps.
- **`hackathon` branch:** a push runs a **Check** stage only — backend and research tests
  (Python 3.11, no `.env`, placeholder settings), frontend typecheck, lint of the hackathon
  screens, and both Docker images built but **not pushed**. It never touches ACR `:latest`
  or the Container Apps. Build and Deploy run only for `main`, whatever triggered the run.
- **Auth:** the pipeline deploys via the `lyra-azure-sc` service connection. You do
  **not** need `az login` or any Azure permissions to deploy.
- **You need:** push access to the Azure Repos git repo. That's it.

## Two separate workflows (they don't conflict)

| Want to change… | Do this | What it triggers |
|---|---|---|
| App code / UI / images | `git push origin main` | ADO pipeline builds + deploys images |
| Infrastructure (identities, scaling, secrets wiring) | `terraform apply` in `terraform/` | Azure API only — **never** runs the pipeline or rebuilds images |
| Add a new secret / config value | `az keyvault secret set --vault-name lyrah-keyvault --name my-thing --value ...` | `keyvault.py` auto-loads it at startup (KV name `my-thing` → env `MY_THING`) |

Terraform ignores the deployed image tag (`ignore_changes`), so `terraform apply`
and pipeline pushes never fight. `terraform plan` currently reports **"No changes"** —
apply is safe.

## What is safe vs. needs care

✅ **Safe** — normal code/UI/config-in-repo changes → just push to `main`.

✅ **Safe** — `terraform apply` (state matches live infra; worst case is a
functionally-identical new revision).

⚠️ **New secret/env var your code needs** — add it to Key Vault first (command
above). `keyvault.py` loads all KV secrets at startup. Only values needed *before
the app imports* (like `DATABASE_URL`) must also be wired in `container_apps.tf`.

⚠️ **New Terraform resource that already exists in Azure** — `terraform import` it
into state before `apply`, or apply will fail trying to create a duplicate.

## Gotchas already solved (don't reintroduce)

Fixed in `main` — listed so you don't undo them (detail in `DEPLOYMENT_STATUS.md`):

- Frontend reads `NEXT_PUBLIC_PYTHON_API_URL` (not `NEXT_PUBLIC_API_URL`); pipeline
  passes it at build time pointing at the stable backend FQDN.
- pnpm workspace nests the Next.js standalone build under `frontend/` — Dockerfile
  CMD is `node frontend/server.js`, assets copied under `frontend/`.
- `start_server.py` loads Key Vault secrets **before** importing the app.
- FHIR/DICOM auth uses the `lyrah-backend-app` registration via `AZURE_FHIR_*` vars,
  kept separate from the managed identity's `AZURE_CLIENT_ID`.
- Key Vault is RBAC-mode: access is a **role assignment** (Key Vault Secrets User),
  not an access policy.

## If a deploy fails

```bash
# logs
az containerapp logs show -n ca-lyra-backend  -g lyra-healthcare-rg --tail 50
az containerapp logs show -n ca-lyra-frontend -g lyra-healthcare-rg --tail 50
# revision health (traffic should be 100 on a Healthy revision)
az containerapp revision list -n ca-lyra-backend -g lyra-healthcare-rg \
  --query "[].{name:name,state:properties.healthState,traffic:properties.trafficWeight}" -o table
```
