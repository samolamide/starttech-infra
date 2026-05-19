# StartTech Infrastructure Runbook

## Prerequisites

- AWS CLI configured (`aws sts get-caller-identity`)
- Terraform >= 1.5
- Access to GitHub repos and Actions secrets

## Deploy infrastructure

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # edit if needed
terraform init
terraform plan
terraform apply
```

Or trigger **Infrastructure Deploy** workflow on `starttech-infra`.

Remote state: `s3://starttech-terraform-state-051826713811/starttech-infra/dev/terraform.tfstate`

## Verify infrastructure

```bash
terraform output
aws elbv2 describe-target-health --target-group-arn "$(terraform output -raw alb_target_group_arn)"
aws elasticache describe-replication-groups --replication-group-id starttech-dev-redis --query ReplicationGroups[0].Status
aws s3 ls s3://$(terraform output -raw frontend_bucket_name)/
```

## CloudWatch

- **Log groups:** `/starttech/dev/backend`, `/starttech/dev/frontend`
- **Dashboard:** `starttech-dev-ops` (Terraform-managed)
- **Alarms:** `starttech-dev-alb-5xx`, `starttech-dev-unhealthy-targets`, `starttech-dev-asg-high-cpu`
- **Queries:** See `monitoring/log-insights-queries.txt`

## Common issues

### Terraform "AlreadyExists" in CI

Cause: CI had empty state while resources existed locally.  
Fix: S3 backend configured; ensure state file exists in state bucket.

### ALB 502 / targets unhealthy

1. **Container crash-loop (Mongo TLS):** Check logs via SSM: `docker logs starttech-backend`. If you see `tls: internal error`, rebuild the backend image (Alpine needs `ca-certificates` in the Dockerfile) and redeploy.
2. **MongoDB Atlas network access:** EC2 instances use the VPC NAT gateway IPs. In Atlas → Network Access → IP Access List, allow:
   - `34.232.251.145/32`
   - `3.216.160.35/32`
   (Re-run `aws ec2 describe-nat-gateways --filter Name=tag:Project,Values=starttech --query 'NatGateways[*].NatGatewayAddresses[0].PublicIp'` if you recreate NAT gateways.)
3. **No container on instance:** Run the backend pipeline in `starttech-application`; confirm SSM is online: `aws ssm describe-instance-information`.

### Redis connection failed

Cause: Wrong `REDIS_ADDR` or security group.  
Fix: Use `terraform output redis_primary_endpoint` with port `:6379`.

## Destroy environment

```bash
cd terraform
terraform destroy
```

**Warning:** Deletes billable resources (NAT gateway, ElastiCache, EC2, etc.).

## Rollback

Infrastructure rollback: revert Terraform commit and `terraform apply`, or restore state from S3 versioning.

Application rollback: see `starttech-application/RUNBOOK.md`.

## Assessor access

See [ASSESSOR_ACCESS.md](./ASSESSOR_ACCESS.md) for IAM permissions required to review this project.
