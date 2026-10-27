.PHONY: up down seed test test-enterprise test-regulator test-analytics lint build-frontend check

up:
	docker compose up -d

down:
	docker compose down

seed:
	PYTHONPATH="protos:database" python -m matryoshka_db.seed_data

lint:
	ruff check .

check: lint test build-frontend

test: test-enterprise test-regulator test-analytics

test-enterprise:
	PYTHONPATH="protos:database:enterprise-service" pytest enterprise-service/tests

test-regulator:
	PYTHONPATH="protos:database:regulator-service" pytest regulator-service/tests

test-analytics:
	PYTHONPATH="protos:analytics-service" pytest analytics-service/tests

build-frontend:
	cd frontend && npm run build
