dashboard "ec2_instance_detail" {

  title         = "AWS EC2 Instance Detail"
  documentation = file("./dashboards/ec2/docs/ec2_instance_detail.md")

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

# Node definition
node "ec2_instance_with_tags" {
  category = category.ec2_instance

  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'Instance ID', instance_id,
        'Type', instance_type,
        'State', instance_state,
        'Tags', tags
      ) as properties
    from
      aws_ec2_instance
    where
      arn = $1
  EOQ

  param "ec2_instance_arn" {}
}