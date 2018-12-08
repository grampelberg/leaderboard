
export HASH ?= $(shell bin/tag.sh)

.PHONY: yaml
yaml:
	@cat leaderboard.yml | envsubst

.PHONY: serve
serve:
	gunicorn \
		-w 1 \
		-k uvicorn.workers.UvicornWorker \
		-b :8080 \
		-e DEV=true \
		--reload \
		leaderboard.app:app

.PHONY: run
run:
	docker-compose -f compose/base.yml up \
		-d \
		--build

.PHONY: sh
sh:
	docker exec -it frontend /bin/sh

.PHONY: dev
dev:
	docker-compose -f compose/base.yml -f compose/dev.yml up \
		-d \
		--build
	-docker exec -it frontend /bin/sh
	$(MAKE) down

.PHONY: build
build:
	docker-compose -f compose/base.yml build

.PHONY: push
push: build
	docker push thomasr/hpa-frontend:$(HASH)

.PHONY: logs
logs:
	docker-compose -f compose/base.yml -f compose/dev.yml logs -f

.PHONY: down
down:
	docker-compose -f compose/base.yml down

.PHONY: update-lock
update-lock:
	pip-compile --output-file requirements.txt requirements.in
