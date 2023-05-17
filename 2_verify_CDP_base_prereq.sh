#!/bin/bash

source ./parameters.sh

verify_prereq() {

    ansible-playbook -i /tmp/CDP_PvC/ansible/hosts $WORKDIR/verify_OS_prereq.yaml
}

echo "Verifying the OS prerequisites on all the hosts."
verify_prereq