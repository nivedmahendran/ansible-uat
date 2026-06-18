.PHONY: deploy status logs ingress restart clean lint validate

deploy:
	ansible-playbook -i inventory.ini deploy.yml --vault-password-file .vault_password

deploy-k3s:
	ansible-playbook -i inventory.ini k3s.yml

deploy-certmanager:
	ansible-playbook -i inventory.ini certmanager.yml

deploy-argocd:
	ansible-playbook -i inventory.ini argocd.yml

status:
	ssh UAT-server 'k3s kubectl get all -n myapp'

logs:
	ssh UAT-server 'k3s kubectl logs -n myapp -l app=app --tail=100'

ingress:
	ssh UAT-server 'k3s kubectl get ingress -n myapp -o wide'

restart:
	ssh UAT-server 'k3s kubectl rollout restart deployment -n myapp app'

clean:
	ssh UAT-server 'k3s kubectl delete all --all -n myapp'

lint:
	yamllint k8s/ deploy.yml docker.yml k3s.yml certmanager.yml argocd.yml
	 ansible-lint deploy.yml docker.yml k3s.yml certmanager.yml argocd.yml

validate:
	k3s kubectl apply -f k8s/ --dry-run=client -o yaml > /dev/null 2>&1 || \
		ssh UAT-server 'k3s kubectl apply -f /opt/myapp/k8s/ --dry-run=client -o yaml > /dev/null 2>&1'
