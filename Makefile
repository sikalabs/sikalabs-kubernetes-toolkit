LONGHORN_VERSION = v1.1.0
ECK_VERSION = 1.3.0

helm-repos:
	helm repo add ondrejsika https://helm.oxs.cz
	helm repo add hashicorp https://helm.releases.hashicorp.com
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
