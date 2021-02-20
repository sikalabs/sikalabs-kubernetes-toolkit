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
	kubectl apply -f ingress/ingress-traefik-consul.yml

uninstall-ingress:
	kubectl delete -f ingress/ingress-traefik-consul.yml

install-ingress-simple:
	kubectl apply -f ingress/ingress-traefik.yml

uninstall-ingress-simple:
	kubectl delete -f ingress/ingress-traefik.yml
