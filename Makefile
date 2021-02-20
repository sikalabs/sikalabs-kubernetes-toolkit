helm-repos:
	helm repo add ondrejsika https://helm.oxs.cz
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm repo update

install-maildev:
	kubectl apply -f k8s/ns-maildev.yml
	helm upgrade --install -n maildev maildev ondrejsika/maildev --set host=mail.k8s.sikademo.com

uninstall-maildev:
	helm uninstall maildev -n maildev
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
