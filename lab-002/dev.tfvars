region        = "us-east-1"
vpc_cidr      = "10.0.0.0/16"
ami_id        = "ami-0c02fb55956c7d316"
instance_type = "t2.micro"

subnets = {
  public = {
    cidr = "10.0.1.0/24"
    type = "public"
  }
  private = {
    cidr = "10.0.2.0/24"
    type = "private"
  }
}

instance_names = ["bastion", "app"]