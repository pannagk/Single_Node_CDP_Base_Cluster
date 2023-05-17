#!/bin/bash
trap 'echo "Setup completed successfully."' 0
set -e

source ./parameters.sh

update_sshd_config() {
    cp /etc/ssh/sshd_config /tmp/CDP_PvC/sshd_config_backup
    sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
    systemctl restart sshd
    systemctl status sshd
    RETURN_VAL=$?
    if [[ "${RETURN_VAL}" == 0 ]]; then
        echo "----------------------------------------"
        echo "sshd restart successful"
    else
        echo "----------------------------------------"
        echo "Seems like there is an issue with sshd. Check the sshd config again."
        echo "The original sshd_config file is present here: /tmp/CDP_PvC/sshd_config_backup"
    fi
}

user_addition(){
    useradd --create-home --shell /bin/bash $USERNAME
    echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME
    usermod -aG wheel $USERNAME
}

install_ansible() {
    yum install epel-release -y
    yum install ansible -y
    yum install figlet -y
    yum install wget -y
    mkdir -p /tmp/CDP_PvC/ansible
}

ansible_config() {
    MASTER_IP=$(hostname -i)
    HOST_KEY_CHECK="ansible_ssh_extra_args='-o StrictHostKeyChecking=no'"
    ANSIBLE_USER="ansible_user=\"$USERNAME\""
    ANSIBLE_PASSWORD="ansible_password=\"$PASSWORD\""
    ANSIBLE_SUDO="ansible_sudo_pass=\"$PASSWORD\""
    HOSTS_LINE="[master]\n${MASTER_IP}\n"
    VARS_LINE="[master:vars]\n$HOST_KEY_CHECK\n$ANSIBLE_USER\n$ANSIBLE_PASSWORD\n$ANSIBLE_SUDO\n"
    echo -e $HOSTS_LINE >> /tmp/CDP_PvC/ansible/hosts
    echo -e $VARS_LINE >> /tmp/CDP_PvC/ansible/hosts
}

echo "Updating the sshd_config to allow password authentication"
update_sshd_config

### Before adding the user check if the user exists
if id -u "$USERNAME" >/dev/null 2>&1; then
  echo "The user $USERNAME exists."
else
  echo "The user $USERNAME not exist. "
  echo "Creating a user for running ansible playbooks"
  user_addition
  fi

echo "Installing ansible and other packages required for completing the prerequisites."
install_ansible

echo "Configuring ansible to run playbooks without hostkey check"
ansible_config

figlet "Pre-Setup Completed"