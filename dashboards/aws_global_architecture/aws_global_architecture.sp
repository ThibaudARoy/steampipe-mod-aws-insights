dashboard "aws_global_architecture" {

  title         = "AWS Global Architecture"
  documentation = file("./dashboards/aws_global_architecture/docs/aws_global_architecture.md")

  tags = merge(local.aws_common_tags, {
    type = "Global"
  })

   container {

    graph {
      title     = "AWS Global Architecture"
      type      = "graph"
      direction = "TD"

      # EC2 related nodes
      node {
        base = node.ec2_instance
        args = {
          ec2_instance_arns = query.all_ec2_instance_arns.rows[*].arn
        }
      }

      node {
        base = node.ec2_key_pair
        args = {
          ec2_instance_arns = query.all_ec2_instance_arns.rows[*].arn
        }
      }

      node {
        base = node.iam_instance_profile
        args = {
          ec2_instance_arns = query.all_ec2_instance_arns.rows[*].arn
        }
      }

      # RDS related nodes
      node {
        base = node.rds_db_instance
        args = {
          rds_db_instance_arns = query.all_rds_db_instance_arns.rows[*].arn
        }
      }

      node {
        base = node.rds_db_parameter_group
        args = {
          rds_db_instance_arns = query.all_rds_db_instance_arns.rows[*].arn
        }
      }

      # Common nodes
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

      node {
        base = node.vpc_security_group
        args = {
          vpc_security_group_ids = query.all_security_group_ids.rows[*].security_group_id
        }
      }

      # EC2 related edges
      edge {
        base = edge.ec2_instance_to_vpc_subnet
        args = {
          ec2_instance_arns = query.all_ec2_instance_arns.rows[*].arn
        }
      }

      edge {
        base = edge.ec2_instance_to_ec2_key_pair
        args = {
          ec2_instance_arns = query.all_ec2_instance_arns.rows[*].arn
        }
      }

      edge {
        base = edge.ec2_instance_to_iam_instance_profile
        args = {
          ec2_instance_arns = query.all_ec2_instance_arns.rows[*].arn
        }
      }

      edge {
        base = edge.ec2_instance_to_vpc_security_group
        args = {
          ec2_instance_arns = query.all_ec2_instance_arns.rows[*].arn
        }
      }

      # RDS related edges
      edge {
        base = edge.rds_db_instance_to_vpc_subnet
        args = {
          rds_db_instance_arns = query.all_rds_db_instance_arns.rows[*].arn
        }
      }

      edge {
        base = edge.rds_db_instance_to_rds_db_parameter_group
        args = {
          rds_db_instance_arns = query.all_rds_db_instance_arns.rows[*].arn
        }
      }

      edge {
        base = edge.rds_db_instance_to_vpc_security_group
        args = {
          rds_db_instance_arns = query.all_rds_db_instance_arns.rows[*].arn
        }
      }

      # Common edges
      edge {
        base = edge.vpc_subnet_to_vpc_vpc
        args = {
          vpc_subnet_ids = query.all_subnet_ids.rows[*].subnet_id
        }
      }
    }
  }
}

# Queries to fetch all necessary ARNs and IDs
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

query "all_security_group_ids" {
  sql = <<-EOQ
    select group_id as security_group_id from aws_vpc_security_group;
  EOQ
}