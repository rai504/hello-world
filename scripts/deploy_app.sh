#!/usr/bin/env bash
set -euo pipefail

PROFILE=${PROFILE:-observability}

# Build WAR
mvn -q -DskipTests package

# Build local Docker image inside Minikube Docker daemon
if command -v minikube >/dev/null 2>&1; then
  eval "$(minikube -p "$PROFILE" docker-env)"
fi

docker build -t webapp:local .

# Deploy app
kubectl apply -f k8s/app/deployment.yaml

kubectl -n app rollout status deploy/webapp --timeout=120s || true
