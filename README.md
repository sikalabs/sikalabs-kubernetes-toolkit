# sikalabs-kubernetes-toolkit

## Traefik ingress controller

### Install

- With consul `make install-ingress`
- Without consul `make install-simple`

## Elastic stack

### Install

- `make helm-repos`
- `make setup-eck`
- `make install-eck`

### Kibana

- URL: https://kibana.k8s.sikademo.com
- User: `elastic`
- Password: `make password-eck`

## Prometheus stack

### Install

- `make helm-repos`
- `make setup-prom`
- `make prom-copy-example-values`
- `make install-prom`

### Prometheus

- Service Discovery - https://prometheus.k8s.sikademo.com/service-discovery
- Targets - https://prometheus.k8s.sikademo.com/targets
- Alerts - https://prometheus.k8s.sikademo.com/alerts
- Graph - https://prometheus.k8s.sikademo.com/graph?g0.range_input=1h&g0.expr=example_requests&g0.tab=1

### Grafana

- URL: https://grafana.k8s.sikademo.com
- User: `admin`
- Password: `prom-operator`

Our example dashboard: https://grafana.k8s.sikademo.com/d/ex01/example-dashboard

### Alert Manager

- https://alertmanager.k8s.sikademo.com
- Status - https://alertmanager.k8s.sikademo.com/#/status
