# Infra

## Installations

### Setting Ansible

Create a virtual environment
```shell
python -m venv .virtual_env
```
Activate
```shell
source .virtual_env/bin/activate
```
Install dependencies
```shell
pip install -r requirements.txt
```
Run Playbook
```shell
ansible-playbook -i inventory.yml site.yml --ask-become-pass
```
