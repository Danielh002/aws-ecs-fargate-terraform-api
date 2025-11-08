# AWS ECS Fargate Node.js API (Terraform)

Production-minded Terraform stack that deploys a containerized Node.js REST API on AWS ECS Fargate with an Application Load Balancer in `us-east-1`. Everything is organized into reusable modules (`vpc`, `alb`, `ecs`) and defaults stay within the AWS Free Tier by running a single Fargate task in public subnets (no NAT Gateway).

## Prerequisites
- Terraform >= 1.6
- AWS account with credentials configured (e.g., via `aws configure`)
- Permission to create VPC, IAM, ECS, and ALB resources in `us-east-1`

## Quick start
1. Clone this repository and move into it.
2. Adjust variables in `variables.tf` or provide a `terraform.tfvars` file (at minimum override `project_name`, `owner`, or `container_image` if desired).
3. Initialize providers/modules:
   ```bash
   terraform init
   ```
4. Review the execution plan:
   ```bash
   terraform plan -var="project_name=node-api" -var="owner=you" -var="container_image=public.ecr.aws/amazonlinux/amazonlinux:latest"
   ```
5. Deploy:
   ```bash
   terraform apply -auto-approve \
     -var="project_name=node-api" \
     -var="owner=you" \
     -var="container_image=public.ecr.aws/docker/library/node:18-alpine"
   ```

## Testing the API
After `apply` completes, Terraform prints the `alb_url` output. Test the service by curling the ALB:
```bash
curl http://<alb_url>
```
Replace `<alb_url>` with the value from `terraform output alb_url`. Ensure your container listens on `container_port` (default 3000) and responds to `GET /` (or update `health_check_path`).

## Staying within the Free Tier
- **Fargate tasks**: Defaults to 0.25 vCPU / 0.5 GB (free-tier friendly) and runs a single task with autoscaling between 1–2 tasks based on CPU.
- **Networking**: Creates both public and private subnets, but ECS tasks run in public subnets with public IPs to avoid the cost of a NAT Gateway. Set `enable_nat_gateway=true` only if you must keep tasks private.
- **Load Balancer**: Single Application Load Balancer on port 80. Delete the stack when idle to stop hourly ALB charges.
- **Logs**: CloudWatch Logs retention defaults to 14 days—tune or disable if needed.
- **Tagging**: All resources tagged with `Environment`, `Project`, and `Owner` for easy cost tracking.

## Module overview
- `modules/vpc`: VPC, subnets (public/private), Internet Gateway, optional NAT Gateway.
- `modules/alb`: Security group, Application Load Balancer, target group, listener.
- `modules/ecs`: ECS cluster, IAM roles, CloudWatch log group, Fargate task definition & service, and Application Auto Scaling.

## Cleanup
Destroy resources when finished to avoid charges:
```bash
terraform destroy
```

## Next steps
- Swap the placeholder image for your API image and wire in environment variables/secrets as TF variables.
- Add ACM certificate + HTTPS listener if you expose production traffic.
- Extend autoscaling (memory metrics, schedule) as load increases.
