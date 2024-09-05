dashboard "aws_global_architecture" {

  title         = "AWS Global Architecture"
  documentation = file("./dashboards/aws/docs/aws_global_architecture.md")

  container {

    card {
      query = query.aws_account
      width = 2
    }

    card {
      query = query.aws_region
      width = 2
    }

  }

  container {

    graph {
      title     = "AWS Global Architecture"
      type      = "graph"
      direction = "TD"

      # EC2 related nodes
      node {
        base = node.ec2_instance
        args = {
          ec2_instance_arns = query.all_ec2_instance_arns.rows[*].instance_arn
        }
      }

      node {
        base = node.ebs_volume
        args = {
          ebs_volume_arns = query.all_ebs_volume_arns.rows[*].volume_arn
        }
      }

      node {
        base = node.ec2_application_load_balancer
        args = {
          ec2_application_load_balancer_arns = query.all_alb_arns.rows[*].alb_arn
        }
      }

      # RDS related nodes
      node {
        base = node.rds_db_instance
        args = {
          rds_db_instance_arns = query.all_rds_instance_arns.rows[*].db_instance_arn
        }
      }

      node {
        base = node.rds_db_cluster
        args = {
          rds_db_cluster_arns = query.all_rds_cluster_arns.rows[*].cluster_arn
        }
      }

      # Shared resources
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
        base = edge.ec2_instance_to_ebs_volume
        args = {
          ec2_instance_arns = query.all_ec2_instance_arns.rows[*].instance_arn
        }
      }

      edge {
        base = edge.ec2_instance_to_vpc_subnet
        args = {
          ec2_instance_arns = query.all_ec2_instance_arns.rows[*].instance_arn
        }
      }

      # RDS related edges
      edge {
        base = edge.rds_db_cluster_to_rds_db_instance
        args = {
          rds_db_cluster_arns = query.all_rds_cluster_arns.rows[*].cluster_arn
        }
      }

      edge {
        base = edge.rds_db_instance_to_vpc_security_group
        args = {
          rds_db_instance_arns = query.all_rds_instance_arns.rows[*].db_instance_arn
        }
      }

      # Shared resource edges
      edge {
        base = edge.vpc_subnet_to_vpc_vpc
        args = {
          vpc_subnet_ids = query.all_subnet_ids.rows[*].subnet_id
        }
      }
    }
  }
}

# Queries to fetch all resources
query "all_ec2_instance_arns" {
  sql = <<-EOQ
    select
      arn as instance_arn
    from
      aws_ec2_instance
  EOQ
}

query "all_ebs_volume_arns" {
  sql = <<-EOQ
    select
      arn as volume_arn
    from
      aws_ebs_volume
  EOQ
}

query "all_alb_arns" {
  sql = <<-EOQ
    select
      arn as alb_arn
    from
      aws_ec2_application_load_balancer
  EOQ
}

query "all_rds_instance_arns" {
  sql = <<-EOQ
    select
      arn as db_instance_arn
    from
      aws_rds_db_instance
  EOQ
}

query "all_rds_cluster_arns" {
  sql = <<-EOQ
    select
      arn as cluster_arn
    from
      aws_rds_db_cluster
  EOQ
}

query "all_vpc_ids" {
  sql = <<-EOQ
    select
      vpc_id
    from
      aws_vpc
  EOQ
}

query "all_subnet_ids" {
  sql = <<-EOQ
    select
      subnet_id
    from
      aws_vpc_subnet
  EOQ
}

query "all_security_group_ids" {
  sql = <<-EOQ
    select
      group_id as security_group_id
    from
      aws_vpc_security_group
  EOQ
}

query "aws_account" {
  sql = <<-EOQ
    select
      'AWS Account' as label,
      account_id as value
    from
      aws_account
    limit 1
  EOQ
}

query "aws_region" {
  sql = <<-EOQ
    select
      'AWS Region' as label,
      region as value
    from
      aws_region
    where
      region = $1
  EOQ

  param "region" {}
}