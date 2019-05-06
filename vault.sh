VAULT_ID='myVAULT@2018'
echo $VAULT_ID > .vault_pass.txt

ANSIBLE_USER='root' # ssh用户名
ANSIBLE_PASSWORD='root' # ssh用户密码

ansible-vault encrypt_string --vault-id .vault_pass.txt $ANSIBLE_USER --name 'vault_ansible_user' | tee dev/group_vars/vault
ansible-vault encrypt_string --vault-id .vault_pass.txt $ANSIBLE_PASSWORD --name 'vault_ansible_password' | tee -a dev/group_vars/vault
