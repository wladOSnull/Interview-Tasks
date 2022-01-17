# Solution for interview challenge

This file contain 3 solution to the interview tasks from ScalHihe. Each block consist of:
- from *Task-#* to *Outcomes* - what **i did** to solve the task:
  - you can do each step if you want to solve task by yourself and will not use my files (from folder Task-#)
  - you can just read all steps if you want to know how is was done

- *Outcomes*: what is enough to done to get result **quick**:
  - do each steps only from *Oucomes* if you want to see results by using my files (from folder Task-#)

<br> <br>

## Task-1

**Vagrant on host**
- create folder Task-1

- *cd* to this folder

- create a Vagrantfile, describe:  
  - used OS  
  - config for network

- run the Vagrantfile and get access to vm:
  ```bash
  # validating and running
  ~ vagrant validate
  ~ vagrant up
  ~ vagrant status
  
  # connecting to  vm via vagrant
  ~ vagrant ssh
  ```

**Configuring backend on the VM**
- presetings:
  ```bash
  # to perform all comands as root (login/pass: vagrant)
  ~ su
  
  # to update yum packages but discard downloading
  ~ no | yum update
  ~ yum install -y yum-utils
  ```

- installing apps:
  ```bash
  # for docker and docker daemon
  ~ yum-config-manager \
      --add-repo \
      https://download.docker.com/linux/centos/docker-ce.repo
  ~ yum install -y docker-ce docker-ce-cli containerd.io
  ~ systemctl start docker
  ~ systemctl status docker
  
  # for docker-compose
  ~ curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  ~ chmod +x /usr/local/bin/docker-compose
  
  # for git
  ~ yum install -y git
  ```

**Running project on the VM**
- get project:
  ```bash
  ~ git clone https://github.com/dataengi/crm-seed.git
  ~ cd ./crm-seed
  ```

- run containers:
  ```bash
  ~ docker-compose --file ./docker-compose.yml up
  ```

</br> </br>  

### *Outcomes*  
To solve this task:
- all previous steps should be performed in turn

- open web browser on host

- visit pages of CRM:
   - http://192.168.56.3  
   or  
   - http://localhost:8030/  

A result of accessing to the site with VM IP:  
![image](screenshots/task1_v1.png?raw=true "screenshot of CRM server on http://192.168.56.3")

A result of accessing to the site from localhost:  
![image](screenshots/task1_v2.png?raw=true "screenshot of CRM server on http://localhost:8030")

<br> <br>  

---
---
---

<br> <br>

## Task-2

**Running Vagrant+Ansible on host**
- create folder Task-2

- *cd* to this folder

- create a Vagrantfile, describe:  
  - used OS  
  - config for network  
  - call point of *ansible_local*  

- create *ansible* folder in Task-2

- cd to this folder

- create playbook.yaml in current folder, describe:
  - each steps from Task-1

- optionally #1:
  ```bash
  # primary files validating 
  ~ vagrant validate
  ~ ansible-playbook ./ansible/playbook.yaml --check
  ```

- run the Vagrantfile:
  ```bash
  # running the vm
  ~ vagrant up
  ```
  
  - optionally #2:
  ```bash
  # checking status of VM
  ~ vagrant status
  
  # connecting to the VM
  ~ vagrant ssh
  ```

</br> </br>  

### *Outcomes*  
For this task was wrtitten two versions of vagrant files. Task-2 folder contain 2 subfolders:
- Task-2.1 - has a Vagrantfile with callpoint for *ansible_local* (for Ansible previously **auto installed into VM by Vagrant**)

- Task-2.2 -  has a Vagrantfile with callpoint for *ansible* (for Ansible that should be previously **installed on host machine by user**)

To solve this task:
- *cd* to any subfolder of Task-2

- just run vagrant file

- open web browser on host

- visit pages of CRM:
   - for Task-2.1:
      - http://192.168.56.4  
      or  
      - http://localhost:8040/  

    - for Task-2.2:
      - http://192.168.56.5  
       or  
      - http://localhost:8050/  

Also you can run them paralell, as shown in the picture:  
![image](screenshots/task2_type1_type2.png?raw=true "screenshot of 2 CRM servers on 2 different VMs")

<br> <br>

---
---
---

<br> <br>

## Task-3

This chapter contains 2 parts:
- short text variant of the guide to installing Ansible AWX from web site: [Computing for Geeks](https://computingforgeeks.com/how-to-install-ansible-awx-on-ubuntu-linux/)

- provisioning a VM with playbook.yaml from Task-2 by Ansible AWX  

</br> </br>

### Installation of k3s  

**Update Linux system**
- preparing system to installing future apps and libraries:
  ```bash
  ~ sudo apt update && sudo apt -y upgrade
  ~ sudo reboot
  ```

**Install single node k3s Kubernetes**
- downloading k3s:
  ```bash
  ~ curl -sfL https://get.k3s.io | sudo bash -
  ~ sudo chmod 644 /etc/rancher/k3s/k3s.yaml
  ~ sudo apt update
  ```

- add *kubectl* autocomplete:
  ```bash
  ~ source <(kubectl completion bash)
  ~ echo "source <(kubectl completion bash)" >> ~/.bashrc
  ```

</br> </br>

### Installation of Ansible AWX  

**Deploying AWX on k3s**
- installing git and essential utilities for build:
  ```bash
  ~ sudo apt install git build-essential
  ```

- create folder Task-3

- *cd* to this folder

- get the AWX installator - Operator:
  ```bash
  ~ git clone https://github.com/ansible/awx-operator.git
  ```

- create namespace & changing *default* context:
  ```bash
  ~ export NAMESPACE=awx
  ~ kubectl create ns ${NAMESPACE}
  ~ kubectl get namespace
  ~ sudo kubectl config set-context --current --namespace=$NAMESPACE
  ```

- change dir to cloned repo of Operator:
  ```bash
  ~ cd awx-operator/
  ```

- saving the latest version from AWX Operator releases as RELEASE_TAG variable then checking out to the branch using git:
  ```bash
  ~ sudo apt update
  ~ sudo apt install curl jq
  ~ RELEASE_TAG=`curl -s https://api.github.com/repos/ansible/awx-operator/releases/latest | grep tag_name | cut -d '"' -f 4`
  ~ echo $RELEASE_TAG
  ~ git checkout $RELEASE_TAG
  ```

- deploying AWX into cluster:
  ```bash
  ~ export NAMESPACE=awx
  ~ sudo make deploy
  ```

- printing active pods:
  ```bash
  ~ kubectl get pods
  ```
  
**Install Ansible AWX using Operator**
  - create static data PVC-Ref (AWX data persistence):
    ```bash
    ~ cat <<EOF | kubectl create -f -
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: static-data-pvc
    spec:
      accessModes:
        - ReadWriteOnce
      storageClassName: local-path
      resources:
        requests:
          storage: 5Gi
    EOF
    
    ~ kubectl get pvc -n awx
    ```

- creating AWX deployment file:
  ```bash
  ~ nano awx-deploy.yml
  
  # follow content must to be in awx-deploy.yml
  ---
  apiVersion: awx.ansible.com/v1beta1
  kind: AWX
  metadata:
    name: awx
  spec:
    service_type: nodeport
    projects_persistence: true
    projects_storage_access_mode: ReadWriteOnce
    web_extra_volume_mounts: |
      - name: static-data
        mountPath: /var/lib/projects
    extra_volumes: |
      - name: static-data
        persistentVolumeClaim:
          claimName: static-data-pvc
  ```

- applying createed conf manifest:
  ```bash
  # applying
  ~ kubectl apply -f awx-deploy.yml
  
  # printing info about running pods (ctrl+c to quit)
  ~ watch kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator"
  ```

- if there is problem with *CrashLoopBackOff* state of *awx-postgres-0* pod check original [guide](https://computingforgeeks.com/how-to-install-ansible-awx-on-ubuntu-linux/) to solve this error

**Optional steps - for inspecting container`s logs**
- checking AWX Container`s logs:
  ```bash
  # printing all pods
  ~ kubectl get pods
  
  # insert into [brackets] name of awx pod from the output of the previous command 
  # example: awx-75698588d6-r7bxl
  ~ kubectl -n awx logs [awx-pod-name]
  ```

- previous command print an error and give advice to fix that - we need to specify name of a **container** for the **pod** when want to see logs of container:
  ```bash
  # get list of containers from pod 
  # example: redis, awx-web, awx-task, awx-ee
  ~ kubectl get pods [awx-pod-name] -o jsonpath='{.spec.containers[*].name}'
  
  # printing logs of a container 
  # insert into [1th brackets] name of pod and [2th brackets] name of container
  # example: kubectl -n awx  logs awx-75bd7d77d5-wlstf -c awx-we
  ~ kubectl -n awx  logs [awx-pod-name] -c [container-name]
  ```

**Access Ansible AWX Dashboard**
- printing all available services:
  ```bash
  # in this output is important only PORT of awx-service
  ~ kubectl get svc -l "app.kubernetes.io/managed-by=awx-operator"
  ```

- if it is necessary to change port of awx-service check original [guide](https://computingforgeeks.com/how-to-install-ansible-awx-on-ubuntu-linux/) to do this operation

- open web browser on the host machine

- visit [http://localhost:port-of-awx-service/](http://localhost:port-of-awx-service/)

- logining:
  - login - admin
  - password:
    ```bash
    # decoding password from the secret
    ~ kubectl get secret awx-admin-password -o jsonpath="{.data.password}" | base64 --decode
    ```

At this step you must to get access to AWX Dashboard from your usual web browser, for example:  
![image](screenshots/task3.1_dashboard.png?raw=true "active AWX Dashboard on localhost")

</br>

**Info about Nodes**
- reviewing Kubernetes Node resources to ensure they are enough to run AWX:
  ```bash
  ~ kubectl top nodes --use-protocol-buffers
  ```

**Important info about using this service**
- in normal condition, after rebooting host machine, k3s services must to rerun by itself and AWX Dashboard will be accessible again  

- if something does not work - check logs, visit original [guide](https://computingforgeeks.com/how-to-install-ansible-awx-on-ubuntu-linux/), check comments under that guide - enjoy :D

- there may be also a problem with executing *kubectl* commands and you will have to rerun:
  ```bash
  # granting rights to correctly execute kubectl commands without sudo
  ~ sudo chmod 644 /etc/rancher/k3s/k3s.yaml
  ```

- to check pods and everything else, firstly you have to change context namespace:
  ```bash
  # printing all namespaces
  # if Dashboard work, there must be namespace with it's pods - awx (according to the guide above)
  ~ kubectl get namespace
  
  # changing default namespace to awx, to perform all commands to this context
  ~ sudo kubectl config set-context --current --namespace=awx
  
  # geting info about running pods
  ~ kubectl get pod
  ```

!!! **Uninstall AWX Operator**
- for this Task you DONT HAVE TO uninstall Operator, but for future and if you really need this info (example: for reinstall):
  ```bash
  # don’t run this unless you’re sure it uninstalls!
  ~ export NAMESPACE=awx
  ~ sudo make undeploy
  ```

</br> </br>  


### Provisioning ver.1: Vagrant - Host

This is first version of solution for this task. In this case Ansible AWX configured the VM on host machine running by Vagrant.

---

### A VM deploying

**Deploying of a simple VM**
- *cd* to folder Solutions

- create directory "ssh_key_pair"

- *cd* to this folder

- create ssh key pair
  ```bash
  # generating ssh key pair
  ~ ssh-keygen
  
  # then input PATH to new file and it's NAME
  # otherwise the utilite ssh-keygen would rewrite dafault ssh key pair in /home/user/.ssh/
  
  # leave a passphrase string blank
  ```

- *cd* to Task-3 folder

- create a Vagrantfile, describe:  
  - used OS  

  - config for network

  - provisioning the created ssh key pair

- run the Vagrantfile:
  ```bash
  # validating and running
  ~ vagrant validate
  ~ vagrant up
  ~ vagrant status
  ```

- optionally:
  ```bash
  # connecting to  vm via vagrant
  ~ vagrant ssh
  ```

</br> </br>  

### Configuring Ansible AWX

**Creating base resources**
- login to AWX Dashboard

- tab Inventories:
  - *Add*
  - Name: inventory1
  - Description: Task-3.1
  - Organization: Default
  - *Save*

- tab Inventory again

- subtab Hosts:
  - *Add*
  - Name: ip address of CentOS VM launched in chapter "A VM deploying"
  - Description: Vagrant-CentOS
  - *Save*

- tab Credentials:
  - *Add*
  - Name: Vagrant-CentOS
  - Description: Task-3.1
  - Organization: Default
  - Credential Type: Machine
  - Type Details:
    - Username: vagrant (default username of Vagrant VMs)
    - SSH Private Key: Browse -> choose file of private ssh key created in chapter "A VM deploying"
    - Privilege Escalation Method: sudo
    - Privilege Escalation Password: vagrant (default password of Vagrant VMs)
  - *Save*

**Optionally steps for checking performed configurations**
- login into AWX Dashboard:
  
  - tab Inventories: inventory1
  - subtab: Hosts
  - select host with name of CentOS VM ip address
  - *Run Command* (near *Add*):
    - 1 Details:
      - Module: shell
      - Arguments: touch /home/vagrant/AWX_file
    - 2 Execution Environment:
      - select "Control Plane Execution Environment"
    - 3 Credentia:
      - select "Vagrant-CentOS"
    - 4 Preview:
      - *Launch*
  
  - Dashbord redirect us to Output page

  - after 5-8s. Dashboard print results

- then login to CentOS VM via VMBox / host's terminall / etc ...

- username/password: vagrant

- check if Ansible AWX really established connection to VM and executed that command (or "job" - in terminology of Ansible AWX):
  ```bash
  ~ ls ~
  # or
  ~ ls /home/vagrant/
  ```
- if there is *AWX_file* created by Ansible AWX via ad hoc command - everything works correctly

The illustration of correctly executed ad hoc command from Ansible AWX on the VM:  
![image](screenshots/task3.1_ad_hoc.png?raw=true "executed adf hoc command")

</br> </br>  

### Final ver.1

**Creating necessary 'resources' for provisioning the VM**
-  login into AWX Dashboard

- tab Projects:
  - *Add*
    - Name: my_first
    - Description: playbooks on github
    - Organization: Default
    - Source Control Credential Type: Git
    - Source Control URL: https://github.com/wladOSnull/Interview-Tasks/
    - Source Control Branch/Tag/Commit: devops_engineer_task_job_offer_level
    - select checkboxes: "Clean" and "Update Revision on Launch"
  - *Save*

 - if all is OK "Last Jb Status" get "Successful"

- tab Projects
  - click on "my_first"
    - subtab "Job Templates"
    - *Add*
      - Name: simple_job
      - Description: playbook from git repo
      - Job Type: Run
      - Inventory: select "inventory1" (with the VM host)
      - Project: select "my_first"
      - Playbook: select "devops_engineer_task/Solutions/ansible/playbook.yaml" (this path AWX parses and finds by itself if Project was synced successfully)
      - Credentials: select "Vagrant-CentOS"
    - *Save*

**Provisioning**
- tab Templates

- click on 'rocket' near previously created template (simple_job)

- Dashbord redirect us to Output page

- if everything is ok - all Tasks will pass

- check results, for that open web browser on host and visit pages of CRM (ip of the VM)

</br> </br>  

### Provisioning ver.2: Terraform - AWS

This is second version of solution for this task. In this case Ansible AWX configured an AMI on AWS EC2 instance deployed via Terraform.

---

### Deploying an AMI on EC2 instance

First steps with Terraform and AWS were done earlier on SoftServe DevOps course, so *Setup* chapter is not detail.

**Setup**
- creating AWS profile  

- creating IAM user for AWS profile  

- saving credentials of IAM user on the host machine

- installing *terraform* on the host machine

- generating ssh key pair for AMI  

- picking up of CentOS AMI id on [Cloud/AWS](https://wiki.centos.org/Cloud/AWS)

- developing *.tf* file for deploying CentOS on to EC2 instance by terraform using created IAM user with credentials and new generated ssh key pair !

**Running terraform deploying**
- *cd* into folder with *.tf* file:
  ```bash
  # file validating
  ~ terraform validate -json
  
  # for initializing working directory 
  ~ terraform init
  
  # writting plan of deplying into file "plan"
  ~ terraform plan -out=plan

  # applying "plan" / deploying
  ~ terraform apply plan
  ```

- ssh private key is insecure after creating, so:
  ```bash
  # it is required that the private key files are NOT accessible by others
  # replace [brackets] with path to your created private ssh key file
  ~ sudo chmod 400 [private ssh key file]

  # after this using private ssh key can be possible
  ```

- loginig to AWS Cloud Console (your [AWS profile](https://console.aws.amazon.com/console/home?nc2=h_ct&src=header-signin) actually):
   - Services:
     - Compute:
       - EC2:
        - Instances
          - select deployed AMI
          - Public IPv4 address: copy an address (necessary for Ansible AWX)
          - select Connect
            - Example: copy the generated string for connection to AMI via ssh (optionally)

**Optionally**
- connecting to AMI (monitoring and interacting with the AMI) by using copied connection string from the last step:
  ```bash
  # input into first [brackets] path to private ssh key for AMI
  # in real case there will be ipv4 address of the AMI instead of zeros
  ~ ssh -i [name of ssh key file] centos@ec2-000-000-000-000.eu-central-1.compute.amazonaws.com
  ```

</br> </br>  

### Configuring Ansible AWX

**Creating base resources**
- login to AWX Dashboard

- tab Inventories:
  - *Add*
  - Name: inventory_aws_single
  - Description: AWS EC2 instance
  - Organization: Default
  - *Save*

- tab Inventory again

- subtab Hosts:
  - *Add*
  - Name: public ipv4 ip address of AMI
  - Description: EC2 CentOS
  - *Save*

- tab Credentials:
  - *Add*
  - Name: Terraform-CentOS
  - Description: Task-3.2
  - Organization: Default
  - Credential Type: Machine
  - Type Details:
    - Username: centos
    - SSH Private Key: Browse -> select file of private ssh key created in chapter "Setup"
    - Privilege Escalation Method: sudo su
  - *Save*

- tab Projects
  - click on "my_first"
    - subtab "Job Templates"
    - *Add*
      - Name: simple_job_aws
      - Description: provisioning EC2 instance
      - Job Type: Run
      - Inventory: select "inventory_aws_single" (with the AMI)
      - Project: select "my_first"
      - Execution Environment: se;ect "Control Plane Execution Environment"
      - Playbook: select "devops_engineer_task/Solutions/ansible/playbook.yaml"
      - Credentials: select "Terraform-CentOS"
    - *Save*

</br> </br>

### Final ver.2

**Provisioning**
- tab Templates

- click on 'rocket' near previously created template (simple_job_aws)

- Dashbord redirect us to Output page

- if everything is ok - all Tasks will pass

- check results, for that open web browser on host and visit pages of CRM (public ipv4 of AMI)

</br> </br>  

### *Outcomes*

---

### *Outcomes for ver.1*

For this task you have to perform entire guide above:
- installing k3s

- deploying Ansible AWX on k3s

- generating ssh key pair

- deploying the VM with CentOS (with using Vagrant file from Task-3 folder)

- configuring of Ansible AWX (with using playbook.yaml from my public github repo)

Then the VM can finally be configured via Ansible AWX:
- run *template* on AWX Dashboard

- open web browser on host

- visit pages of CRM:
  - http://192.168.56.6  
  or  
  - http://localhost:8060/ 

An example of results:  
![image](screenshots/task3.1_finall.png?raw=true "CRM on the VM provisioned by Ansible AWX deployed via k3s")

</br> </br>  

### *Outcomes for ver.2*  

For this task you have to perform entire guide above:
- setup

- creating or using my .tf file for deploying AMI  

- configuring Ansible AWX

- provisioning by AWX Dashboard

Then the CRM server can be accessed by:
- open web browser on host

- visit pages of CRM:
  - [http://ipv4-address-of-the-AMI]  

An example of results:  
![image](screenshots/task3.2_final.png?raw=true "CRM on the AMI provisioned by Ansible AWX deployed via Terraform")
