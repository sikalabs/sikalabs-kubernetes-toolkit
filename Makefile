helm-repos:
	helm repo add ondrejsika https://helm.oxs.cz
	helm repo update

install-maildev:
	kubectl apply -f k8s/ns-maildev.yml
	helm upgrade --install -n maildev maildev ondrejsika/maildev --set host=mail.k8s.sikademo.com

uninstall-maildev:
	helm uninstall maildev -n maildev
	kubectl delete -f k8s/ns-maildev.yml