#!/usr/bin/env bash
set -euo pipefail

PROFILE=${PROFILE:-observability}

minikube status -p "$PROFILE" >/dev/null 2>&1 || minikube start -p "$PROFILE" --kubernetes-version=v1.30.0 --memory=4096 --cpus=4

minikube -p "$PROFILE" addons enable ingress || true

kubectl get ns observability >/dev/null 2>&1 || kubectl apply -f k8s/observability/namespace.yaml
kubectl get ns app >/dev/null 2>&1 || kubectl apply -f k8s/app/namespace.yaml

# Add Helm repos
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo update >/dev/null

# Install Loki + Promtail
helm upgrade --install loki grafana/loki --namespace observability -f helm-values/loki.yaml
helm upgrade --install promtail grafana/promtail --namespace observability -f helm-values/promtail.yaml

# Install Tempo
helm upgrade --install tempo grafana/tempo --namespace observability -f helm-values/tempo.yaml

# Install Prometheus
helm upgrade --install prometheus prometheus-community/prometheus --namespace observability -f helm-values/prometheus.yaml

# Install Grafana
helm upgrade --install grafana grafana/grafana --namespace observability -f helm-values/grafana.yaml

# OpenTelemetry Collector
kubectl apply -f k8s/observability/otel-collector.yaml

# Wait for pods
kubectl -n observability rollout status deploy/otel-collector --timeout=120s || true
