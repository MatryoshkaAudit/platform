.PHONY: up down seed test test-enterprise test-regulator build-frontend

up:
	docker compose up -d

down:
	docker compose down

seed:
	PYTHONPATH="protos:database" python -m matryoshka_db.seed_data

test: test-enterprise test-regulator

test-enterprise:
	PYTHONPATH="protos:database:enterprise-service" pytest enterprise-service/tests

test-regulator:
	PYTHONPATH="protos:database:regulator-service" pytest regulator-service/tests

build-frontend:
	cd frontend && npm run build
