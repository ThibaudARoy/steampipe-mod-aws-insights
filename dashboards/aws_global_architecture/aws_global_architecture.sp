dashboard "aws_global_architecture" {
  title         = "AWS Global Architecture"
  documentation = file("./dashboards/aws_global_architecture/docs/aws_global_architecture.md")

  input "instance_arn" {
    title = "Select an instance:"
    query = query.ec2_instance_input_new
    width = 4
  }

  container {
    graph {
      title     = "EC2 Instance and Tags"
      type      = "graph"
      direction = "TD"

      node {
        base = node.ec2_instance
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      node {
        base = node.ec2_instance_tags
        args = {
          ec2_instance_arn = self.input.instance_arn.value
        }
      }

      edge {
        base = edge.ec2_instance_to_tags
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

# Node queries
query "ec2_instance_node" {
  sql = <<-EOQ
    select
      arn as id,
      title as title,
      jsonb_build_object(
        'Instance ID', instance_id,
        'Type', instance_type,
        'State', instance_state,
        'VPC ID', vpc_id,
        'Subnet ID', subnet_id,
        'Private IP', private_ip_address,
        'Public IP', public_ip_address,
        'EBS Optimized', ebs_optimized
      ) as properties
    from
      aws_ec2_instance
    where
      arn = any($1);
  EOQ

  param "ec2_instance_arns" {}
}

query "ec2_instance_tags_node" {
  sql = <<-EOQ
    select
      arn || ':' || tag ->> 'Key' as id,
      tag ->> 'Key' as title,
      jsonb_build_object(
        'Key', tag ->> 'Key',
        'Value', tag ->> 'Value'
      ) as properties
    from
      aws_ec2_instance,
      jsonb_array_elements(tags_src) as tag
    where
      arn = $1;
  EOQ

  param "ec2_instance_arn" {}
}

# Edge query
query "ec2_instance_to_tags_edge" {
  sql = <<-EOQ
    select
      arn as from_id,
      arn || ':' || tag ->> 'Key' as to_id
    from
      aws_ec2_instance,
      jsonb_array_elements(tags_src) as tag
    where
      arn = $1;
  EOQ

  param "ec2_instance_arn" {}
}