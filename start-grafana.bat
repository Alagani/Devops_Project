@echo off
echo Starting Grafana on http://localhost:3000
echo Username: admin
echo Password: admin
echo Press Ctrl+C to stop
kubectl port-forward -n monitoring svc/grafana 3000:3000
