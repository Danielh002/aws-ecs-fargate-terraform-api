# AWS ECS Fargate Fullstack (Terraform)

Production-minded Terraform stack that deploys the expenses tracker backend (NestJS API) and frontend (React SPA) as two ECS Fargate services behind a single Application Load Balancer in `us-east-1`. Path-based routing sends `/api/*` traffic to the backend task while all other paths land on the frontend. Everything is organized into reusable modules (`vpc`, `alb`, `ecs`) and defaults stay within the AWS Free Tier by running the tasks in public subnets (no NAT Gateway).

## Prerequisites
- Terraform >= 1.6
- AWS account with credentials configured (e.g., via `aws configure`)
- Permission to create VPC, IAM, ECS, and ALB resources in `us-east-1`
- Two ECR repositories that you create manually (for example, `expenses-tracker-backend` and `expenses-tracker-frontend`). Terraform expects the image URIs and will not create the repositories for you—see *Build & push container images*.

## Quick start
1. Clone this repository and move into it.
2. Start from `dev.tfvars`/`prod.tfvars` and tweak values there (tags, extra routes, etc.). Those files already capture the free-tier defaults so you typically only override `backend_container_image` / `frontend_container_image` per environment.
3. Initialize providers/modules:
   ```bash
   terraform init
   ```
4. Review the execution plan, pointing Terraform at the env file and only overriding the two image URIs:
   ```bash
   terraform plan \
     -var-file=dev.tfvars \
     -var="backend_container_image=123456789012.dkr.ecr.us-east-1.amazonaws.com/expenses-tracker-backend:v1" \
     -var="frontend_container_image=123456789012.dkr.ecr.us-east-1.amazonaws.com/expenses-tracker-frontend:v1"
   ```
5. Deploy with the same flags (swap `dev.tfvars` for `prod.tfvars` when needed):
   ```bash
   terraform apply \
     -var-file=dev.tfvars \
     -var="backend_container_image=123456789012.dkr.ecr.us-east-1.amazonaws.com/expenses-tracker-backend:v1" \
     -var="frontend_container_image=123456789012.dkr.ecr.us-east-1.amazonaws.com/expenses-tracker-frontend:v1"
   ```

## Testing the stack
After `apply` completes, Terraform prints `alb_url`.

### Backend
```bash
curl http://$(terraform output -raw alb_url)/api/health
```

### Frontend
Open the `alb_url` root in your browser to verify the React build is served. Because the SPA now defaults to the current origin, API calls automatically hit `<alb_url>/api/...`, but you can still override via `VITE_API_URL` during local dev or testing.

### CORS
`backend_allowed_origins` (list) controls which origins the NestJS API accepts. Terraform also appends the ALB DNS name automatically and ships it via the `FRONTEND_ORIGINS` env var so browsers hitting the load balancer won’t see CORS errors.

## Staying within the Free Tier
- **Fargate tasks**: Defaults to 0.25 vCPU / 0.5 GB for both services and runs a single task per service with autoscaling between 1–2 tasks based on CPU.
- **Networking**: Creates both public and private subnets, but ECS tasks run in public subnets with public IPs to avoid the cost of a NAT Gateway. Set `enable_nat_gateway=true` only if you must keep tasks private.
- **Load Balancer**: Single Application Load Balancer on port 80. Delete the stack when idle to stop hourly ALB charges.
- **Logs**: CloudWatch Logs retention defaults to 14 days—tune or disable if needed.
- **Tagging**: All resources tagged with `Environment`, `Project`, and `Owner` for easy cost tracking.

## Module overview
- `modules/vpc`: VPC, subnets (public/private), Internet Gateway, optional NAT Gateway.
- `modules/alb`: Security group, Application Load Balancer, frontend target group, listener (default action). A backend path rule is defined in the root module.
- `aws_ecs_cluster` (root): Single ECS cluster reused by both services so you only pay for one control plane.
- `modules/ecs`: IAM roles, CloudWatch log group, Fargate task definition & service, and Application Auto Scaling. Instantiated twice (backend + frontend) and pointed at the shared cluster.

## Build & push container images
1. Create two ECR repositories (or reuse existing ones) for backend and frontend:
   ```bash
   aws ecr create-repository --repository-name expenses-backend
   aws ecr create-repository --repository-name expenses-frontend
   ```
2. Build + push the backend container:
   ```bash
   cd expenses-tracker/backend
   docker build -t <acct>.dkr.ecr.us-east-1.amazonaws.com/expenses-backend:latest .
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <acct>.dkr.ecr.us-east-1.amazonaws.com
   docker push <acct>.dkr.ecr.us-east-1.amazonaws.com/expenses-backend:latest
   ```
3. Build + push the frontend container:
   ```bash
   cd expenses-tracker/frontend
   docker build -t <acct>.dkr.ecr.us-east-1.amazonaws.com/expenses-frontend:latest .
   docker push <acct>.dkr.ecr.us-east-1.amazonaws.com/expenses-frontend:latest
   ```
4. Update `backend_container_image` and `frontend_container_image` (in `dev.tfvars`, `prod.tfvars`, or CLI vars) with the pushed image URIs. Store secrets/env vars in SSM Parameter Store or Secrets Manager and reference them from the ECS task definition for production use.

## Cleanup
Destroy resources when finished to avoid charges:
```bash
terraform destroy
```

## Next steps
- Swap the placeholder backend/frontend images for the URIs produced by `build_and_push.sh`.
- Add ACM certificates + HTTPS listeners if you expose production traffic.
- Extend autoscaling (memory metrics, schedule) as load increases or adjust `backend_path_patterns`/listener priorities if exposing additional services.
