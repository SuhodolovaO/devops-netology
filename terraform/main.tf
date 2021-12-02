provider "aws" {
   region = "eu-north-1"
}

data "aws_ami" "amazon_linux" {
	most_recent = true
	owners      = ["amazon"]
	filter {
		name = "name"
		values = ["amzn-ami-hvm-*-x86_64-gp2"]
	}
	filter {
		name = "owner-alias"
		values = ["amazon"] 
	}
}

locals {
	netology_instance_types = {
		stage = "t3.micro"
		prod = "t3.large"
	}
	netology_instance_count = {
		stage = 1
		prod = 2
	}
	netology2_instances = {
		"t3.micro" = data.aws_ami.amazon_linux.id   
		"t3.large" = data.aws_ami.amazon_linux.id
	}
}

resource "aws_instance" "netology" {
	ami = data.aws_ami.amazon_linux.id
	instance_type = local.netology_instance_types[terraform.workspace]
	count = local.netology_instance_count[terraform.workspace]
	
	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_instance" "netology-2" {
	for_each = local.netology2_instances
	
	ami = each.value
	instance_type = each.key
}