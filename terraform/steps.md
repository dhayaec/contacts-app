What YOU need to do (your side)

1. Install & Authenticate

# Install Terraform (https://terraform.hashicorp.com/downloads)

aws configure # enter your AWS access key, secret, region (us-east-1) 2. Create State Backend (one-time, ~2 minutes)

# Create S3 bucket for state

aws s3api create-bucket --bucket contacts-app-tfstate --region us-east-1
aws s3api put-bucket-versioning --bucket contacts-app-tfstate --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking

aws dynamodb create-table \
 --table-name contacts-app-tflock \
 --attribute-definitions AttributeName=LockID,AttributeType=S \
 --key-schema AttributeName=LockID,KeyType=HASH \
 --billing-mode PAY_PER_REQUEST \
 --region us-east-1 3. Uncomment the Backend Block
In terraform/provider.tf, uncomment the backend "s3" block (lines 16–24).

4. Run Terraform (one-time setup)

cd terraform
terraform init
terraform plan
terraform apply 5. Push Your Docker Image (one-time)

# Get ECR login token

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Build and push initial image

docker build -t contacts-app .
docker tag contacts-app:latest <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/contacts-app:initial
docker push <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/contacts-app:initial 6. Set Up GitHub Secrets (for automated CI/CD)
In GitHub repo → Settings → Secrets and variables → Actions, add:

Secret Value
AWS_ACCESS_KEY_ID Your IAM user's access key
AWS_SECRET_ACCESS_KEY Your IAM user's secret
AWS_ACCOUNT_ID Your 12-digit account number
TF_STATE_BUCKET contacts-app-tfstate
TF_LOCK_TABLE contacts-app-tflock 7. Push to Main Branch

git add .
git commit -m "feat: initial deployment setup"
git push origin main
GitHub Actions will then build, push new image, and run terraform apply automatically on every future push.

Summary
Task Who does it
Creating AWS resources (VPC, ECS, ALB, etc.) Terraform (automatic)
State backend (S3 + DynamoDB) You (one-time, 2 commands)
Auth setup (aws configure) You (one-time)
Initial Docker push to ECR You (one-time)
GitHub Secrets You (one-time)
Future builds + deploys GitHub Actions (automatic on push)
