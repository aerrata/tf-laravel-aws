variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "instance_profile_name" { type = string }

resource "aws_ecs_cluster" "this" {
  name = "next-app-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "next-app-"
  image_id      = "ami-0b254e8c46c2cc634"
  instance_type = "t4g.micro"

  iam_instance_profile {
    name = var.instance_profile_name
  }
}

# ASG
resource "aws_autoscaling_group" "this" {
  vpc_zone_identifier = var.subnet_ids
  desired_capacity    = 1
  min_size            = 1
  max_size            = 3

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "this" {
  name = "next-app-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.this.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 10
    }
  }
}


# EC2 instance role

# Key pair

# Security group
resource "aws_security_group" "this" {
  name   = "next-app-ecs-cluster-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "next-app-ecs-cluster-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#####################################################

# resource "aws_launch_template" "ecs" {
#   name_prefix   = "ecs-lt-"
#   image_id      = data.aws_ami.ecs.id
#   instance_type = "t4g.micro"
#   key_name      = "next-app-key"

#   block_device_mappings {
#     device_name = "/dev/xvda"

#     ebs {
#       volume_size = 30
#       volume_type = "gp2"
#     }
#   }

#   iam_instance_profile {
#     name = aws_iam_instance_profile.ecs.name
#   }

#   user_data = base64encode(file("${path.module}/user_data.sh"))
# }

# resource "aws_iam_role" "ecs" {
#   name = "ecsInstanceRole"

#   assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
# }

# data "aws_iam_policy_document" "ecs_assume_role" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_instance_profile" "ecs" {
#   name = "ecsInstanceProfile"
#   role = aws_iam_role.ecs.name
# }

# resource "aws_autoscaling_group" "ecs" {
#   name                = "ecs-asg"
#   desired_capacity    = 1
#   max_size            = 3
#   min_size            = 1
#   vpc_zone_identifier = var.subnet_ids
#   launch_template {
#     id      = aws_launch_template.ecs.id
#     version = "$Latest"
#   }
#   tag {
#     key                 = "AmazonECSCluster"
#     value               = aws_ecs_cluster.this.name
#     propagate_at_launch = true
#   }
# }


