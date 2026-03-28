region        = "eu-central-1"
vpc_cidr      = "10.1.0.0/16"
ami_id        = "ami-0a628e1e89aaedf80"
instance_type = "t2.micro"

subnets = {
  public = {
    cidr = "10.1.1.0/24"
    type = "public"
  }
  private = {
    cidr = "10.1.2.0/24"
    type = "private"
  }
}

instance_names = ["bastion", "app"]