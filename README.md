# DevOpsProject

# 🚀 AWS DevOps Infrastructure with Terraform

This repository contains the Terraform code and configurations for provisioning a scalable, secure, and containerized cloud infrastructure on AWS. The project includes auto-scaling EC2 instances, RDS databases, a load balancer, Dockerized frontend/backend apps, and a BI tool (Metabase) — all orchestrated using Infrastructure as Code.

---

## 📌 Objective

To build a **production-ready AWS environment** using Terraform that supports:

- Auto Scaling EC2 instances with **Docker**, **Nginx**, and **Node.js 20**
- **Private RDS** (MySQL and PostgreSQL) instances
- **Application Load Balancer** with HTTPS support
- Dockerized **Frontend + Backend**
- Deployment of a **BI Tool** (Metabase)
- **SSH tunneling** via Bastion host for secure access
- **Live dashboards** reflecting DB updates

---

## 🧱 Infrastructure Components

### 1. EC2 Auto Scaling Group
- Auto Launches 3 EC2 instances using a Launch Template.
- EC2 installs:
  - Nginx
  - Docker
  - Node.js 20
- Hosts the Dockerized application served through Nginx on port 8080.

### 2. RDS Databases
- MySQL and PostgreSQL deployed in **private subnets**.
- No public IP; accessed via **SSH tunneling**.
- DB Clients like **DBeaver** used for management and dummy data population.

### 3. Security Groups
- Strict access control using multiple security groups:
  - Bastion: SSH access only from user IP
  - EC2: App ports (8080), internal access
  - RDS: Access only from EC2 and Metabase
  - ALB: Only HTTP (80) and HTTPS (443)

### 4. Load Balancer
- AWS Application Load Balancer (ALB)
- Listens on ports 80 and 443
- Forwards to EC2 backend target group

### 5. Dockerized Applications
- Multi-stage Dockerfile for React frontend
- Docker build and run commands handled via EC2 user-data or manually
- GitHub repo: [https://github.com/Khhafeez47/reactapp](https://github.com/Khhafeez47/reactapp)

### 6. Bastion Host
- Public EC2 instance acting as jump box
- Used to SSH into private EC2 and RDS
- SSH tunneling commands used for DB and Metabase access

### 7. Metabase (BI Tool)
- Deployed via Docker on EC2 in private subnet
- Connected to MySQL RDS
- Dashboard reflects real-time data updates

---

## 🛠️ Key Technologies

- **Terraform**
- **AWS EC2, RDS, ALB, VPC**
- **Docker & Docker Compose**
- **Metabase**
- **DBeaver**
- **Bastion SSH Tunneling**
- **Git/GitHub**

---

## 🧩 Terraform Modules Used

- `vpc.tf`: Creates VPC, subnets, NAT, IGW
- `ec2.tf`: Defines EC2 ASG, Launch Templates, Bastion
- `alb.tf`: ALB, Listener, Target Groups
- `rds.tf`: MySQL and PostgreSQL RDS
- `security_groups.tf`: All firewall rules
- `variables.tf`, `outputs.tf`: Parameter management and outputs

---

## 🔐 SSH & Tunneling Commands

```bash
# Copy key to Bastion
scp -i devops-key.pem devops-key.pem ec2-user@<bastion-public-ip>:/home/ec2-user/

# SSH into Bastion
ssh -i devops-key.pem ec2-user@<bastion-public-ip>

# From Bastion to Private EC2
chmod 400 devops-key.pem
ssh -i devops-key.pem ec2-user@<private-ec2-ip>

# Tunnel RDS and Metabase
ssh -i devops-key.pem -L 3306:mysql-rds-endpoint:3306 \
                      -L 5432:postgres-rds-endpoint:5432 \
                      -L 3000:<metabase-private-ip>:3000 ec2-user@<bastion-public-ip>


Limitations
Route53 & ACM SSL not implemented due to permission constraints

Manual SSL setup and custom domain not completed

Metabase only connected to MySQL (PostgreSQL optional)


.
├── main.tf
├── vpc.tf
├── ec2.tf
├── rds.tf
├── alb.tf
├── security_groups.tf
├── variables.tf
├── outputs.tf
└── README.md


Abdullah Khan
DevOps Final Project — 2025
GitHub: AbdullahKhan728

