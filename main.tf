module "vpc" {
  source    = "./modules/vpc"
  
  #Vpc Vars
  name      = "vpc"
  cidr      = "10.0.0.0/16"
  tenancy   = "default"

  #Subnets Vars
  public_subnets  = ["10.0.0.0/24","10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24","10.0.3.0/24"]
  azs             = ["us-east-2a","us-east-2b"]
  default_cidr    = "0.0.0.0/0"

  #Common tags  
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}