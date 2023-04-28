module "vpc" {
  source = "../modules/vpc"
}

module "subnet" {
  source = "../modules/subnet"
  vpc_id = module.vpc.vpc_id
}

module "security_group" {
  source = "../modules/security_group"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source             = "../modules/ec2"
  subnet_id          = module.subnet.subnet_id
  security_group_ids = [module.security_group.security_group_id]
  instance_type      = "t2.micro"
  ami_id             = "ami-0c94855ba95c71c99" # Change this to your desired AMI ID
}
