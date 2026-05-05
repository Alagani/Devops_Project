@echo off
echo Starting Prometheus on http://localhost:9090
echo Press Ctrl+C to stop
kubectl port-forward -n monitoring svc/prometheus 9090:9090
