.PHONY: install dev dev-backend dev-frontend lint test clean

VENV := .venv
PYTHON := $(VENV)/Scripts/python
PIP := $(VENV)/Scripts/pip

install: install-backend install-frontend

install-backend:
	python -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r backend/requirements_cleaned.txt

install-frontend:
	cd frontend && npm install

dev-backend:
	cd backend && $(CURDIR)/$(VENV)/Scripts/uvicorn ehr.app.main:app --reload --port 8000

dev-frontend:
	cd frontend && npm run dev

lint-frontend:
	cd frontend && npm run lint

test-backend:
	cd backend && $(CURDIR)/$(VENV)/Scripts/pytest ehr/tests/ -v

clean:
	rm -rf $(VENV) frontend/.next frontend/node_modules
	find backend -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find backend -name "*.pyc" -delete 2>/dev/null || true
