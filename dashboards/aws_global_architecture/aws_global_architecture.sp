dashboard "aws_global_architecture" {
  title         = "AWS Global Architecture"
  documentation = file("./dashboards/aws_global_architecture/docs/aws_global_architecture.md")

  tags = merge(local.ec2_common_tags, {
    type = "Detail"
  })