# StartTech Infrastructure

Terraform project for the Month 3 assessment: VPC, ALB, ASG, S3, CloudFront, ElastiCache Redis, CloudWatch dashboard/alarms, and ECR.

**Documentation:** [ARCHITECTURE.md](./ARCHITECTURE.md) · [RUNBOOK.md](./RUNBOOK.md) · [ASSESSOR_ACCESS.md](./ASSESSOR_ACCESS.md)

## What gets created

| Component | Purpose |
|-----------|---------|
| VPC + subnets | Network isolation (public ALB, private EC2/Redis) |
| ALB + target group | Routes HTTP to backend on port 8080, health check `/health` |
| Auto Scaling Group | 1–3 EC2 instances running the Golang API (Docker deployed in Phase 2) |
| ElastiCache Redis | Sessions/cache for the backend |
| S3 + CloudFront | Hosts the React frontend (private bucket, CDN in front) |
| CloudWatch log groups | Central logging for backend and frontend |
| CloudWatch dashboard + alarms | Ops metrics (ALB, ASG, unhealthy targets) |
| ECR | Backend Docker image registry |
| IAM role | EC2: CloudWatch logs, SSM, ECR pull |

MongoDB runs on **MongoDB Atlas** (not Terraform). Connection strings belong in secrets, not in this repo.

## Prerequisites

1. AWS account with IAM user `terraform-user` (or similar) and programmatic access keys.
2. [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
3. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured:

   ```bash
   aws configure
   aws sts get-caller-identity
   ```

4. MongoDB Atlas cluster (already set up) and **Network Access** allowing AWS egress IPs or `0.0.0.0/0` for dev.

## Terraform state (S3 backend)

State is stored in `s3://starttech-terraform-state-051826713811/starttech-infra/dev/terraform.tfstate` so local runs and GitHub Actions share the same state.

First-time setup (after cloning):

```bash
aws s3 mb s3://starttech-terraform-state-051826713811 --region us-east-1  # skip if exists
cd terraform
terraform init -migrate-state   # moves local state to S3 (answer yes)
```

## Deploy (local)

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars if needed

terraform init
terraform plan
terraform apply
```

Or from repo root:

```bash
bash scripts/deploy-infrastructure.sh
```

## Important outputs (after apply)

- `alb_dns_name` — backend API URL (Phase 2 CI/CD uses this)
- `cloudfront_domain_name` — frontend URL
- `redis_primary_endpoint` — set as `REDIS_ADDR` on the backend
- `frontend_bucket_name` — S3 sync target for React build

## Security

- Do **not** commit `terraform.tfvars` or `infra-aws` credentials.
- Use GitHub Actions secrets for MongoDB URI, JWT secret, etc. in Phase 2.

## Repository layout

```
terraform/
  main.tf, variables.tf, outputs.tf, versions.tf
  modules/networking/   # VPC, SGs, Redis
  modules/compute/      # ALB, ASG, IAM
  modules/storage/      # S3, CloudFront
  modules/monitoring/   # CloudWatch logs, dashboard, alarms
monitoring/             # Log Insights queries, alarm reference JSON
.github/workflows/      # infrastructure-deploy.yml
```

## CI/CD

`.github/workflows/infrastructure-deploy.yml` — Terraform plan/apply on push (uses S3 remote state).
