PROFILE ?= observability

.PHONY: bootstrap deploy app grafana-port-forward tempo-port-forward prometheus-port-forward

bootstrap:
	PROFILE=$(PROFILE) bash scripts/minikube_bootstrap.sh

deploy:
	PROFILE=$(PROFILE) bash scripts/deploy_app.sh

app: deploy

# Helpful port-forwards (Grafana default creds admin/admin)

grafana-port-forward:
	kubectl -n observability port-forward svc/grafana 3000:80

tempo-port-forward:
	kubectl -n observability port-forward svc/tempo 3100:3100

prometheus-port-forward:
	kubectl -n observability port-forward svc/prometheus-server 9090:80
