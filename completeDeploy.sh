ansible-playbook ./playbooks/setup_local.yaml -i ./inventory/inventory.yaml
ansible-playbook ./playbooks/docker_infra.yaml -i ./inventory/inventory.yaml
ansible-playbook ./playbooks/nginx_hosts.yaml -i ./inventory/inventory.yaml
ansible-playbook ./playbooks/prometheus_host.yaml -i ./inventory/inventory.yaml
ansible-playbook ./playbooks/test_services.yaml -i ./inventory/inventory.yaml
