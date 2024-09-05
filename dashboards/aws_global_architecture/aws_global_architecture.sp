dashboard "aws_global_architecture" {

  title         = "AWS Global Architecture"
  documentation = file("./dashboards/aws/docs/aws_global_architecture.md")

  tags = merge(local.aws_common_tags, {
    type = "Global"
  })

  container {

    graph {
      title     = "AWS Global Architecture"
      type      = "graph"
      direction = "TD"

      node {
        base = node.ec2_instance
        args = {
          ec2_instance_arns = query.all_ec2_instance_arns.rows[*].arn
        }
      }

      node {
        base = node.rds_db_instance
        args = {
          rds_db_instance_arns = query.all_rds_db_instance_arns.rows[*].arn
        }
      }

      node {
        base = node.vpc_vpc
        args = {
          vpc_vpc_ids = query.all_vpc_ids.rows[*].vpc_id
        }
      }

      node {
        base = node.vpc_subnet
        args = {
          vpc_subnet_ids = query.all_subnet_ids.rows[*].subnet_id
        }
      }

      edge {
        base = edge.ec2_instance_to_vpc_subnet
        args = {
          ec2_instance_arns = query.all_ec2_instance_arns.rows[*].arn
        }
      }

      edge {
        base = edge.rds_db_instance_to_vpc_subnet
        args = {
          rds_db_instance_arns = query.all_rds_db_instance_arns.rows[*].arn
        }
      }

      edge {
        base = edge.vpc_subnet_to_vpc_vpc
        args = {
          vpc_subnet_ids = query.all_subnet_ids.rows[*].subnet_id
        }
      }
    }
  }
}

query "all_ec2_instance_arns" {
  sql = <<-EOQ
    select arn from aws_ec2_instance;
  EOQ
}

query "all_rds_db_instance_arns" {
  sql = <<-EOQ
    select arn from aws_rds_db_instance;
  EOQ
}

query "all_vpc_ids" {
  sql = <<-EOQ
    select vpc_id from aws_vpc;
  EOQ
}

query "all_subnet_ids" {
  sql = <<-EOQ
    select subnet_id from aws_vpc_subnet;
  EOQ
}