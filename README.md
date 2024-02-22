
# DPE_task

Terraform + AWS


## Setup 
- Follow `terraform` and `aws cli` tutorials to install software
- For `aws cli` follow https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- In AWS project create IAM service account (ex. `infra_setup_service`) with programmatical access, assign `AdministratorAccess` policy
- Example tutorial to follow https://www.techtarget.com/searchcloudcomputing/tutorial/Step-by-step-guide-on-how-to-create-an-IAM-user-in-AWS
- Download service account credentials with ID and password, run `aws configure` and set pemisions
- cd to `infra` folder and run `terraform init && terraform apply`
