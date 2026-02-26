.PHONY: venv install install-dev test lint format clean run

PYTHON := python3
VENV := venv
BIN := $(VENV)/bin

venv:
	$(PYTHON) -m venv $(VENV)

install: venv
	$(BIN)/pip install -r requirements.txt

install-dev: install
	$(BIN)/pip install -r requirements-dev.txt
	$(BIN)/pip install -e .

test: install-dev
	$(BIN)/pytest -v

lint: install-dev
	$(BIN)/black --check src tests
	$(BIN)/isort --check src tests
	$(BIN)/mypy src tests

format: install-dev
	$(BIN)/black src tests
	$(BIN)/isort src tests

clean:
	rm -rf $(VENV) __pycache__ .pytest_cache .coverage
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

run: install
	$(BIN)/python -m mssql_mcp_server
