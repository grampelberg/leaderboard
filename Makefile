
export HASH ?= $(shell bin/tag.sh)

.PHONY: yaml
yaml:
	@cat leaderboard.yml | envsubst

# ==============================================================================
# Development
# ==============================================================================

.PHONY: serve
serve:
	gunicorn \
		-w 1 \
		-k uvicorn.workers.UvicornWorker \
		-b :8080 \
		-e DEV=true \
		-e PORT=6379 \
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

# ==============================================================================
# Demo
# ==============================================================================

.PHONY: setup-system
setup-system:
	linkerd install | kubectl apply -f -

	helm repo update
	helm -n linkerd --namespace linkerd \
		install stable/prometheus-adapter \
		-f hpa/prometheus-adapter.yml

.PHONY: verify-system
verify-system:
	kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq .

	kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/leaderboard/pods/*/response_latency_ms_99th" | \
	  jq .

.PHONY: demo
demo:
	$(MAKE) yaml | kubectl apply -f -

	kubectl apply -f external.yml -f load.yml

	kubectl -n leaderboard get deploy -o yaml | \
		linkerd inject - | \
		kubectl apply -f -

	kubectl apply -f hpa/policy.yml

.PHONY: schema
schema:
	curl http://localhost:8001/api/v1/namespaces/leaderboard/services/web:http/proxy/schema | \
		linkerd -n leaderboard profile web --open-api - | \
		kubectl apply -f -

