PROMETHEUS_OPERATOR_VERSION = v0.47.0
LONGHORN_VERSION = v1.1.0
ECK_VERSION = 1.4.0

helm-repos:
	helm repo add ondrejsika https://helm.oxs.cz
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add stable https://charts.helm.sh/stable
	helm repo update

install-maildev:
	kubectl apply -f k8s/ns-maildev.yml
	helm upgrade --install \
		maildev ondrejsika/maildev \
		-n maildev \
		--set host=mail.k8s.sikademo.com

uninstall-maildev:
	helm uninstall maildev \
		-n maildev
	kubectl delete -f k8s/ns-maildev.yml

install-consul:
	kubectl apply -f k8s/ns-consul.yml
	helm upgrade --install \
		consul hashicorp/consul \
		-n consul \
		-f values/consul/general.yml

uninstall-consul:
	helm uninstall consul \
		-n consul
	kubectl delete -f k8s/ns-consul.yml

install-ingress:
	kubectl apply -f k8s/ingress/ingress-traefik-consul.yml

uninstall-ingress:
	kubectl delete -f k8s/ingress/ingress-traefik-consul.yml

install-ingress-simple:
	kubectl apply -f k8s/ingress/ingress-traefik.yml

uninstall-ingress-simple:
	kubectl delete -f k8s/ingress/ingress-traefik.yml

install-longhorn:
	kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/$(LONGHORN_VERSION)/deploy/longhorn.yaml

uninstall-longhorn:
	kubectl delete -f https://raw.githubusercontent.com/longhorn/longhorn/$(LONGHORN_VERSION)/deploy/longhorn.yaml

make-longhorn-default-storageclass:
	kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
	
do-make-longhorn-default-storageclass:
	kubectl patch storageclass do-block-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
	kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

install-longhorn-ingress:
	kubectl apply -f k8s/longhorn/longhorn-ingress.yml

uninstall-longhorn-ingress:
	kubectl delete -f k8s/longhorn/longhorn-ingress.yml

setup-eck:
	kubectl apply -f https://download.elastic.co/downloads/eck/$(ECK_VERSION)/all-in-one.yaml

install-eck:
	kubectl apply -f k8s/ns-eck.yml
	kubectl apply -f k8s/eck

uninstall-eck:
	kubectl delete -f k8s/eck
	kubectl delete -f k8s/ns-eck.yml

password-eck:
	@echo "USER:"
	@echo "elastic"
	@echo ""
	@echo "PASSWORD: "
	@kubectl -n elastic-stack get secret eck-es-elastic-user -o go-template='{{.data.elastic | base64decode}}'
	@echo ""
	@echo ""

setup-prom:
	kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$(PROMETHEUS_OPERATOR_VERSION)/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
	kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$(PROMETHEUS_OPERATOR_VERSION)/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
	kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$(PROMETHEUS_OPERATOR_VERSION)/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
	kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$(PROMETHEUS_OPERATOR_VERSION)/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
	kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$(PROMETHEUS_OPERATOR_VERSION)/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
	kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$(PROMETHEUS_OPERATOR_VERSION)/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml

install-prom:
	kubectl apply -f k8s/ns-prom.yml
	helm upgrade --install \
		prometheus-stack prometheus-community/kube-prometheus-stack \
		-n prometheus-stack \
		-f values/prom/general.yml \
		-f valeus/prom/general-override.yml \
		-f values/prom/ingress.yml \
		-f values/prom/alertmanager-config.yml

uninstall-prom:
	helm uninstall prometheus-stack \
		 -n prometheus-stack
	kubectl delete -f k8s/ns-prom.yml

prom-reload:
	curl -X POST https://prometheus.k8s.sikademo.com/-/reload
	curl -X POST https://alertmanager.k8s.sikademo.com/-/reload

prom-copy-example-values:
	cp values/prom/ingress.example.yml values/prom/ingress.yml
	cp values/prom/alertmanager-config.example.yml values/prom/alertmanager-config.yml

delete-stuck-namespace:
	kubectl get namespace "${ns}" -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/${ns}/finalize -f -
