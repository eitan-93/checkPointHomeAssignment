## Project Overview

This project defines a Python microservice (`microserviceTest`) that polls currency rates and serves them over HTTP.

- Infrastructure is provisioned using **Terraform**.
- The microservice is packaged as a **Docker** container and deployed to an **ECS cluster (EC2 launch type)**.
- An **ELB (Elastic Load Balancer)** distributes traffic to the ECS service.
- An **Auto Scaling Group** with an ECS-optimized AMI manages EC2 instances for the cluster.
- **Terraform** configures ECS services, task definitions, networking, and SSM parameter integration.
- The microservice retrieves secure secrets (API keys) from **AWS SSM Parameter Store** at runtime.
- **GitHub Actions** is used for CI/CD: it builds the Docker image, pushes it to **ECR**, and triggers `terraform apply`.
- **GitHub Actions** For manageability I also created a workflow for terraform to destroy.
