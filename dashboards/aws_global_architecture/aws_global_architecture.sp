dashboard "aws_global_architecture" {

  title         = "AWS Global Architecture Detail"
  documentation = file("./dashboards/aws_global_architecture/docs/aws_global_architecture_detail.md")

  input "instance_arn" {
    title = "Select an instance:"
    query = query.ec2_instance_input_new
    width = 4
  }

  container {
    graph {
      title     = "EC2 Instance Tags"
      type      = "graph"
      direction = "TD"

      node {
        base = node.ec2_instance_with_tags
        args = {
          ec2_instance_arn = self.input.instance_arn.value
        }
      }
    }
  }
}

# Input query
query "ec2_instance_input_new" {
  sql = <<-EOQ
    select
      title as label,
      arn as value
    from
      aws_ec2_instance
    order by
      title;
  EOQ
}