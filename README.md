# Lyrah Healthcare System

Full-stack healthcare platform running on Azure.

## Architecture

| Layer | Stack |
|---|---|
| Backend | Python 3.11 · FastAPI · uvicorn |
| Frontend | Next.js 16 · React 19 · TypeScript |
| Database | Azure PostgreSQL Flexible Server (3 databases) |
| Clinical data | Azure Health Data Services — FHIR R4 |
| Imaging | Azure Health Data Services — DICOM · DR7/MedGemma |
| Storage | Azure Blob Storage |
| AI | Azure OpenAI (GPT-4o) · AutoGen · LangChain |

The backend is a single unified FastAPI process. `backend/ehr/app/main.py` mounts
all five modules (ehr, diagtool, inventory\_management, reg\_and\_sched, research\_assistant)
as one app. Start it once to get every route.

## Prerequisites

- Python 3.11+
- Node.js 18+
- npm (or pnpm — see workspace setup below)

## Backend Setup

```bash
python -m venv .venv
# Windows:
.venv\Scripts\activate
# macOS/Linux:
source .venv/bin/activate

pip install -r backend/requirements_cleaned.txt
```

Copy the example env file and fill in your Azure credentials:

```bash
cp backend/ehr/.env.example backend/ehr/.env
```

## Start the Backend

Run from the `backend/` directory so Python finds the module packages:

```bash
cd backend
uvicorn ehr.app.main:app --reload --port 8000
```

| URL | Purpose |
|---|---|
| `http://127.0.0.1:8000/` | Health / root |
| `http://127.0.0.1:8000/api/v1` | EHR, scheduling, diagnostics |
| `http://127.0.0.1:8000/api/v1/inventory` | Inventory management |
| `http://127.0.0.1:8000/research` | Research assistant |

## Frontend Setup

```bash
cd frontend
npm install
```

Optional — set a custom backend URL:

```bash
# frontend/.env.local
NEXT_PUBLIC_PYTHON_API_URL=http://127.0.0.1:8000/api/v1
```

If not set, the frontend defaults to `http://127.0.0.1:8000/api/v1`.

## Start the Frontend

```bash
cd frontend
npm run dev
```

Frontend: `http://localhost:3000`

## Recommended Startup Order

1. Start the backend (`cd backend && uvicorn ehr.app.main:app --reload --port 8000`)
2. Start the frontend (`cd frontend && npm run dev`)
3. Open `http://localhost:3000`

## Makefile Shortcuts

From the repo root (requires make):

```bash
make install          # set up venv + pip + npm install
make dev-backend      # start backend on port 8000
make dev-frontend     # start frontend on port 3000
make test-backend     # run pytest
make lint-frontend    # run ESLint
make clean            # remove venv, node_modules, .next, __pycache__
```

## Monorepo Structure

```
healthcare-system/
├── backend/
│   ├── ehr/                    # entry point module — mounts all others
│   ├── diagtool/               # medical imaging AI
│   ├── inventory_management/   # pharmacy stock
│   ├── reg_and_sched/          # doctor scheduling
│   ├── research_assistant/     # medical research agents
│   └── requirements_cleaned.txt  # single consolidated requirements file
├── frontend/                   # Next.js 16 app
├── docs/                       # architecture and deployment guides
├── Makefile
├── package.json                # pnpm workspace root
└── turbo.json                  # build pipeline
```

## Common Issues

### `ModuleNotFoundError` on backend start

You must run uvicorn from inside the `backend/` directory:

```bash
cd backend   # ← required
uvicorn ehr.app.main:app --reload --port 8000
```

Running from repo root breaks the Python module resolution.

### `.env` values not picked up

The unified backend reads `backend/ehr/.env`. Make sure that file exists and
contains values for at minimum: `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`,
`AZURE_CLIENT_SECRET`, `AZURE_FHIR_URL`, `DATABASE_URL`.

See `backend/ehr/.env.example` for the full variable list.
