#!/bin/bash

source ./parameters.sh

enable_pw_less_ssh() {

    ansible-playbook -i /tmp/CDP_PvC/ansible/hosts $WORKDIR/password_less_ssh.yaml
}

check_pw_less_ssh() {

    ansible master -i /tmp/CDP_PvC/ansible/hosts -m ping
    RETURN_VAL=$?
    if [[ "${RETURN_VAL}" == 0 ]]; then
        echo "----------------------------------------"
        echo "Password less ssh is established."
    else
        echo "Verify the ssh key copied in authorized_keys file."
        exit 1
    fi    
}

set_hostname() {

    ansible-playbook -i /tmp/CDP_PvC/ansible/hosts $WORKDIR/set_hostname.yaml
}

setup_prereq() {

    ansible-playbook -i /tmp/CDP_PvC/ansible/hosts $WORKDIR/cdp_base_OS_prereq.yaml
}


echo "Enabling password less ssh to itself."
enable_pw_less_ssh

echo "Validating password less ssh"
check_pw_less_ssh

echo "Set hostnames for the master."
set_hostname

echo "Running all the OS prerequisites on all the hosts."
setup_prereq

echo "---------------------------------------------"
echo "All the CDP Base prerequisites are completed."
echo "---------------------------------------------"

