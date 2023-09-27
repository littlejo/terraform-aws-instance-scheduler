data "aws_instances" "night" {
  instance_tags = {
    Stop = "*Night*"
  }
}

data "aws_instances" "weekend" {
  instance_tags = {
    Stop = "*Weekend*"
  }
}

module "night" {
  source = "../.."
  name   = "toto"
  period = "night"
  type   = "ec2"
  target = data.aws_instances.night.ids
}

module "weekend" {
  source = "../.."
  name   = "toto"
  period = "weekend"
  type   = "ec2"
  target = data.aws_instances.weekend.ids
}
