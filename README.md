# Azure-Cloud-Infrastructure-Automation-Using-Terraform-and-Ansible

## Project Overview

This project demonstrates a complete **Infrastructure as Code (IaC)** implementation for deploying a **3-Tier Web Application** in Microsoft Azure using **Terraform** and **Ansible**.

The application consists of:

* **Frontend** → Next.js (Server-Side Rendering)
* **Backend** → Python REST API
* **Database** → PostgreSQL running inside Docker

The infrastructure is designed following production-style best practices including:

* Remote Terraform State using Azure Blob Storage
* Modular Terraform project structure
* Azure Virtual Network segmentation using multiple subnets
* Bastion-based secure SSH access
* Network Security Groups (NSG) for controlled communication
* Azure Key Vault for secret management
* Managed Identity for secure secret access from backend
* Configuration management using Ansible

---

## Architecture Diagram

<img width="1103" height="745" alt="tf-mega-1 drawio" src="https://github.com/user-attachments/assets/24fa8e1f-33d8-455f-be3b-4bafe7bee616" />


---

### Network Design

VNet: `webapp-vnet (10.0.0.0/16)`

| Subnet          | CIDR        |
| --------------- | ----------- |
| bastion-subnet  | 10.0.0.0/24 |
| frontend-subnet | 10.0.1.0/24 |
| backend-subnet  | 10.0.2.0/24 |
| database-subnet | 10.0.3.0/24 |

---

## Infrastructure Components

## Virtual Machines

### Bastion VM

* Name: `bastion-vm`
* Private IP: `10.0.0.4`
* Public IP: Enabled
* Purpose:

  * Secure SSH access
  * Ansible execution host

---

### Backend VM

* Name: `backend-vm`
* Private IP: `10.0.2.4`
* Public IP: Disabled
* Purpose:

  * Runs Python REST API
  * Accesses Azure Key Vault using Managed Identity

### NSG Rules

* Allow Port `5000` from frontend subnet
* Allow SSH Port `22` only from bastion subnet

---

### Database VM

* Name: `database-vm`
* Private IP: `10.0.3.4`
* Public IP: Disabled
* Purpose:

  * Runs PostgreSQL inside Docker

### NSG Rules

* Allow PostgreSQL access from backend subnet
* Allow SSH Port `22` only from bastion subnet

> Note: PostgreSQL container exposes port `5432`. Ensure NSG rules match the actual application port.

---

## Azure Key Vault

Used for securely storing database credentials:

* `db-host`
* `db-name`
* `db-user`
* `db-password`

### Access Configuration

### Your Access

Role Assigned:

* `Key Vault Administrator`

This is required to manually create secrets.

### Backend VM Access

Configured with:

* System Assigned Managed Identity

Role Assigned:

* `Key Vault Secrets User`

This allows the backend application to securely fetch secrets without storing credentials in code.

---

## Frontend Deployment

Frontend is deployed using **Azure Container Apps**

### Container App Environment

* Public Network Access: Enabled
* Virtual IP: External

### Container App

* Name: `frontend-con-app`
* Image:
  `gimhan764/tier3-app-1-frontend:v1`
* Registry: Other Registry
* Region: East US

### Environment Variable

```env
BACKEND_API=http://backend-vm:5000/api/fruits
```

### Ingress Configuration

* Accept traffic from anywhere
* Target Port: `80`
* Insecure Connections: Allowed

---

## Technologies Used

## Infrastructure

* Terraform
* Azure Virtual Network
* Azure Virtual Machines
* Azure NSG
* Azure Key Vault
* Azure Managed Identity
* Azure Container Apps
* Azure Blob Storage (Remote State)

## Configuration Management

* Ansible

## Application Stack

* Next.js (SSR)
* Python REST API
* PostgreSQL
* Docker
* Ubuntu Server 24.04 LTS

---

## Project Structure

```text
│   .gitignore
│   backend.tf
│   main.tf
│   outputs.tf
│   providers.tf
│   README.md
│   terraform.tfvars
│   variables.tf
│   versions.tf
│
├───ansible-files
│   │   backend.yml
│   │   database.yml
│   │
│   ├───backend-files
│   │       app.py
│   │       requirements.txt
│   │
│   ├───db-files
│   │       init.sql
│   │
│   └───inventory
│           hosts.ini
│
└───modules
    ├───backend-vm
    │       main.tf
    │       outputs.tf
    │       variables.tf
    │
    ├───bastion-vm
    │       main.tf
    │       outputs.tf
    │       variables.tf
    │
    ├───database
    │       main.tf
    │       outputs.tf
    │       variables.tf
    │
    ├───frontend-container-app
    │       main.tf
    │       outputs.tf
    │       variables.tf
    │
    ├───keyvault
    │       main.tf
    │       outputs.tf
    │       variables.tf
    │
    ├───networking
    │       main.tf
    │       outputs.tf
    │       variables.tf
    │
    └───resource-group
            main.tf
            outputs.tf
            variables.tf
```

---

# Deployment Guide

---

## Step 1 — Setup Terraform Remote State

Create a separate resource group:

```bash
az group create \
  --name tfstate-rg \
  --location eastus
```

Create storage account:

```bash
az storage account create \
  --name tier3apptfstate \
  --resource-group tfstate-rg \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2
```

Create blob container:

```bash
az storage container create \
  --name tfstate \
  --account-name tier3apptfstate
```

---

## Step 2 — Deploy Infrastructure using Terraform

```bash
cd terraform

terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

---

## Step 3 — Install Ansible on Bastion VM

Login to Bastion VM:

```bash
ssh appuser@<Bastion-Public-IP>
```

Default credentials:

```text
Username: appuser
Password: Password@123
```

Install Ansible:

```bash
sudo su

apt-add-repository ppa:ansible/ansible
apt update
apt install ansible -y
```

---

## Step 4 — Copy Ansible Files to Bastion

Clone the ansible-files to your machine. From local machine:

```bash
scp -r ./ansible-files appuser@<Bastion-Public-IP>:/home/appuser/
```

---

## Step 5 — Configure SSH Access

Generate SSH key:

```bash
ssh-keygen
```

Copy SSH key to target VMs:

```bash
ssh-copy-id appuser@backend-vm
ssh-copy-id appuser@database-vm
```

---

## Step 6 — Configure Database Server

Run:

```bash
ansible-playbook -i inventory/hosts.ini database.yml
```

This will:

* Install Docker
* Run PostgreSQL container
* Import database schema and seed data

Equivalent Docker commands:

```bash
docker run -d \
  --name postgres-fruit \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin \
  -e POSTGRES_DB=fruitdb \
  -p 5432:5432 \
  postgres
```

```bash
docker exec -i postgres-fruit \
  psql -U admin -d fruitdb < /tmp/init.sql
```

---

## Step 7 — Create Key Vault Secrets

Add role:

* `Key Vault Administrator`

Create these secrets manually:

| Secret Name | Value       |
| ----------- | ----------- |
| db-host     | database-vm |
| db-name     | fruitdb     |
| db-user     | admin       |
| db-password | admin       |

---

## Step 8 — Configure Backend Server

Run:

```bash
ansible-playbook -i inventory/hosts.ini backend.yml
```

This will:

* Install Docker
* Configure backend environment
* Fetch secrets from Key Vault
* Deploy Python REST API

---

Full application code: https://github.com/GimhanPerera/sample-tier3-web-application.git

---

## Author

**Gimhan Perera**

---
