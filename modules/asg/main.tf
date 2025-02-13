resource "aws_launch_template" "this" {
  name_prefix   = var.asg.name_prefix
  image_id      = var.asg.image_id
  instance_type = var.asg.instance_type
    iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }
vpc_security_group_ids = var.asg.vpc_security_group_ids
}

resource "aws_autoscaling_group" "this" {
  desired_capacity    = var.asg.desired_capacity
  max_size            = var.asg.max_size
  min_size            = var.asg.min_size
  vpc_zone_identifier = var.asg.vpc_zone_identifier

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}

resource "aws_iam_instance_profile" "this" {
  name = "test_profile"
  role = aws_iam_role.role.name
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = "test_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.this.json
}
