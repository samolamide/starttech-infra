# Assessor AWS Access

Provide the assessor an IAM **user** or **role** with programmatic access to review resources in account `051826713811` (region `us-east-1`).

## Recommended managed policies

Attach these AWS managed policies (or equivalent custom policy):

| Policy | Purpose |
|--------|---------|
| `ReadOnlyAccess` | View all resources in console/CLI |
| `AmazonEC2ReadOnlyAccess` | ASG, instances, security groups |
| `ElasticLoadBalancingReadOnly` | ALB, target health |
| `AmazonS3ReadOnlyAccess` | Frontend bucket |
| `CloudFrontReadOnlyAccess` | CDN distribution |
| `AmazonEC2ContainerRegistryReadOnly` | ECR images |
| `CloudWatchReadOnlyAccess` | Logs, dashboard, alarms |
| `AmazonSSMReadOnlyAccess` | SSM command history |

For Terraform apply testing (optional):

- `PowerUserAccess` **or** custom policy scoped to StartTech resource name prefix `starttech-dev-*`

## Verification commands

```bash
aws sts get-caller-identity
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names starttech-dev-asg
aws s3 ls s3://starttech-dev-frontend-051826713811/
aws logs describe-log-groups --log-group-name-prefix /starttech/
```

## Submission checklist

- [ ] GitHub URL: `starttech-application`
- [ ] GitHub URL: `starttech-infra`
- [ ] IAM access key ID + secret (secure channel, not in git)
- [ ] MongoDB Atlas: network access documented (public IP or VPC peering)

**Do not submit** files containing plaintext passwords (`infra-aws`, `terraform.tfvars`).
