# Terraform AWS Web Server Deployment

Terraform code that provisions a small web-server environment on AWS: a custom VPC with a public subnet, internet access, a security group and an EC2 instance that installs and starts Apache on boot. The whole environment is created with `terraform apply` and removed with `terraform destroy`.

## What It Creates

| Resource | Details |
|---|---|
| VPC | `10.1.0.0/16` |
| Public subnet | `10.1.0.0/24` in `us-east-1a`, auto-assigns public IPs |
| Internet gateway + route table | Default route (`0.0.0.0/0`) to the internet, associated with the subnet |
| Security group | Inbound HTTP (80) from anywhere, SSH (22) only from the CIDR you provide; all outbound allowed |
| EC2 instance | `t3.micro` (configurable); a `user_data` script installs and enables Apache (`httpd`) and writes a "Hello from Terraform Web Server" page; IMDSv2 is required and the root volume is encrypted |
| Outputs | `web_server_public_ip` and `web_server_url` |

## Architecture

```
Internet ──▶ Internet Gateway ──▶ Route Table ──▶ Public Subnet (10.1.0.0/24)
                                                        │
                                          EC2 (Apache) + Security Group (80, 22)
```

## Tech Stack

Terraform · AWS (VPC, EC2, Security Groups) · Apache · Linux (Amazon Linux)

## Project Structure

```
.
├── provider.tf     # AWS provider, region us-east-1
├── main.tf         # VPC, subnet, IGW, route table, security group, EC2
├── variables.tf    # instance_type, ami_id, key_name
├── outputs.tf      # public IP and URL
└── README.md
```

## Variables

| Name | Default | Notes |
|---|---|---|
| `instance_type` | `t3.micro` | EC2 instance size |
| `ami_id` | `ami-052064a798f08f0d3` | Amazon Linux AMI; AMI IDs are region-specific, so change it if you change the region |
| `key_name` | none (required) | Name of your own EC2 key pair |
| `ssh_cidr` | none (required) | CIDR allowed to SSH, e.g. your public IP as `203.0.113.10/32` |

## Prerequisites

- Terraform installed
- AWS CLI configured (`aws configure`) with permissions to create these resources
- An existing EC2 key pair in `us-east-1`

## How to Run

```bash
git clone https://github.com/BodusuSneha/Terraform-Project.git
cd Terraform-Project

terraform init      # download the AWS provider
terraform validate  # check the configuration
terraform plan  -var="key_name=<your-key-pair>" -var="ssh_cidr=<your-ip>/32"
terraform apply -var="key_name=<your-key-pair>" -var="ssh_cidr=<your-ip>/32"
```

When it finishes, open the `web_server_url` output in a browser. You should see **Hello from Terraform Web Server**.

To remove everything and avoid AWS charges:

```bash
terraform destroy -var="key_name=<your-key-pair>" -var="ssh_cidr=<your-ip>/32"
```

## What I Learned

- Defining networking and compute as code and previewing changes with `terraform plan`
- Splitting Terraform into provider, variables, resources and outputs files
- Bootstrapping a server automatically with `user_data`
- Why environments built from code are repeatable compared with manual console setup

## Known Limitations / Next Steps

- Store Terraform state remotely (S3 with DynamoDB locking)
- Add an IAM role for the instance and an S3 bucket
- Move the networking into a reusable module

## Author

**Sneha Bodusu**: [GitHub](https://github.com/BodusuSneha) · [LinkedIn](https://linkedin.com/in/sneha-bodusu)
