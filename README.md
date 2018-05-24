-------------------------------------------------------------------------------
## 部署前 ##
1. 己安装好centos 7.3/7.4操作系统
2. 准备ansible环境  
说明: ansible和离线源需要一台额外的主机, 安装完成后即可回收主机

``` shell
# 安装pip
yum -y install python-setuptools
easy_install pip
# 安装ansible
pip install ansible
```

3. 下载ansible-k8s-manifest ansible playbook
``` shell
git clone https://github.com/juneau-work/ansible-k8s-manifest
cd ansible-k8s-manifest
```
> 以下操作都以ansible-k8s-manifest为basedir

4. 配置认证信息
	- i. 复制以下内容生成vault.sh脚本
	``` shell
	cat <<'EOF' > vault.sh
	VAULT_ID='myVAULT@2018'
	echo $VAULT_ID > ~/.vault_pass.txt

	ANSIBLE_USER='root' # ssh用户名
	ANSIBLE_PASSWORD='root' # ssh用户密码

	ansible-vault encrypt_string --vault-id ~/.vault_pass.txt $ANSIBLE_USER --name 'vault_ansible_user' | tee dev/group_vars/vault
	ansible-vault encrypt_string --vault-id ~/.vault_pass.txt $ANSIBLE_PASSWORD --name 'vault_ansible_password' | tee -a dev/group_vars/vault
	EOF
	```
	**注意:** 请务必修改脚本中的ssh用户名密码及dce认证用户名密码与实际环境匹配
	- ii. 执行脚本
	``` shell
	bash vault.sh
	```
   
