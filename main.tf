# introducing terraform with the provider

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# Deploying VM machine 

resource "aws_instance" "new-instance" {
  ami           = "ami-0a749d160bf052e89"
  instance_type = "t2.micro"

  tags = {
    Name = "newinstance"
  }
}

# Deloying monitoring part

resource "aws_cloudwatch_metric_alarm" "vm_metric_alaram" {
  alarm_name                = "vm-metricalert-terraform"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 1
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.email_sns_topic.arn]

  dimensions = {
    InstanceId = aws_instance.new-instance.id
  }
}

# Adding SNS for email regarding the alerts

resource "aws_sns_topic" "email_sns_topic" {
  name = "email-sns-topic"
}

resource "aws_sns_topic_subscription" "email_sns_subscription" {
  topic_arn = aws_sns_topic.email_sns_topic.arn
  protocol  = "email"
  endpoint  = "paulansh286@gmail.com" # Replace with your email address
}
