# deploy-django-application-cicd

## Overview

This project show how to deploy a Django application to AWS ECS using GitHub Actions for CI/CD. The setup includes:

- Dockerized Django app
- Terraform-managed AWS infrastructure
- ECS Fargate service behind an Application Load Balancer
- CI/CD pipeline triggered via GitHub Actions
- Secure every process

---

## Tech Stack

- **Django**: Web framework for the backend application
- **Docker**: Containerization
- **Terraform**: Infrastructure as Code (IaC)
- **AWS ECS (Fargate)**: Container orchestration and deployment
- **Amazon RDS**: PostgreSQL database
- **GitHub Actions**: CI/CD pipeline automation

---

## CI/CD Pipeline

The CI/CD pipeline is divided into three main jobs:

1. **Infrastructure**
   - Provisions AWS resources using Terraform
   - Creates ECR repository and ECS service

2. **Build**
   - Builds the Docker image
   - Saves it as an artifact

3. **Push**
   - Downloads the image
   - Tags and pushes it to ECR
   - ECS service pulls the new image on deploy

4. **Destroy (optional)**
   - Destroys all infrastructure when needed

5. **Exit (optional)**
   - Cancel the Workflow

## How to Use

### 1. Configure Secrets

Set the following GitHub repository secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

### 2. Trigger Workflow

Run the `Build & Deploy Django to ECS` workflow manually from the GitHub Actions tab. You can:

- Select `apply` to provision and deploy
- Select `destroy` to tear down all infrastructure

### 3. Terraform Variables

Make sure `terraform-prod.tfvars` includes:

```hcl
environment = "prod"
cidr_block = [
  {
    name = "vpc-example"
    cidr = "10.0.0.0/16"
  }
]
az = ["zone-1", "zone-2"]

container_port     = port 
cpu                = 1024
memory             = 2048
db_master_password = "hello_pass"
```

---

### More About This Project

For a detailed walkthrough and reasoning behind the architecture, you can read my blog post:

[**Full Project Documentation and Insights**](https://your-blog-link.com)

---
# Let me know if you'd like a tailored version based on your actual project layout or services used.
