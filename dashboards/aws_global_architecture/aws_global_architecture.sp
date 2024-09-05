dashboard "aws_global_architecture" {

  title         = "AWS Global Architecture"
  documentation = file("./dashboards/aws_global_architecture/docs/aws_global_architecture.md")

  input "resource_arn" {
    title = "Select a resource:"
    query = query.resource_input
    width = 4
  }

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

      node {
        base = node.ec2_instance
        args = {
          ec2_instance_arns = [self.input.resource_arn.value]
        }
      }

      node {
        base = node.ebs_volume
        args = {
          ebs_volume_arns = with.ebs_volumes_for_resource.rows[*].volume_arn
        }
      }

      node {
        base = node.ec2_application_load_balancer
        args = {
          ec2_application_load_balancer_arns = with.ec2_application_load_balancers_for_resource.rows[*].application_load_balancer_arn
        }
      }

      node {
        base = node.rds_db_instance
        args = {
          rds_db_instance_arns = with.rds_db_instances_for_resource.rows[*].db_instance_arn
        }
      }

      node {
        base = node.rds_db_cluster
        args = {
          rds_db_cluster_arns = with.rds_db_clusters_for_resource.rows[*].cluster_arn
        }
      }

      node {
        base = node.vpc_vpc
        args = {
          vpc_vpc_ids = with.vpc_vpcs_for_resource.rows[*].vpc_id
        }
      }

      node {
        base = node.vpc_subnet
        args = {
          vpc_subnet_ids = with.vpc_subnets_for_resource.rows[*].subnet_id
        }
      }

      node {
        base = node.vpc_security_group
        args = {
          vpc_security_group_ids = with.vpc_security_groups_for_resource.rows[*].security_group_id
        }
      }

      edge {
        base = edge.ec2_instance_to_ebs_volume
        args = {
          ec2_instance_arns = [self.input.resource_arn.value]
        }
      }

      edge {
        base = edge.ec2_instance_to_vpc_subnet
        args = {
          ec2_instance_arns = [self.input.resource_arn.value]
        }
      }

      edge {
        base = edge.rds_db_cluster_to_rds_db_instance
        args = {
          rds_db_cluster_arns = with.rds_db_clusters_for_resource.rows[*].cluster_arn
        }
      }

      edge {
        base = edge.rds_db_instance_to_vpc_security_group
        args = {
          rds_db_instance_arns = with.rds_db_instances_for_resource.rows[*].db_instance_arn
        }
      }

      edge {
        base = edge.vpc_subnet_to_vpc_vpc
        args = {
          vpc_subnet_ids = with.vpc_subnets_for_resource.rows[*].subnet_id
        }
      }
    }
  }

  container {
    width = 6

    table {
      title = "Overview"
      type  = "line"
      width = 6
      query = query.resource_overview
      args  = [self.input.resource_arn.value]
    }

    table {
      title = "Tags"
      width = 6
      query = query.resource_tags
      args  = [self.input.resource_arn.value]
    }
  }

  container {
    width = 6

    table {
      title = "Security Groups"
      query = query.resource_security_groups
      args  = [self.input.resource_arn.value]
    }
  }
}

# Input query

query "resource_input" {
  sql = <<-EOQ
    select
      title as label,
      arn as value,
      json_build_object(
        'account_id', account_id,
        'region', region,
        'resource_id', coalesce(instance_id, db_instance_identifier)
      ) as tags
    from
      (
        select title, arn, account_id, region, instance_id, null as db_instance_identifier from aws_ec2_instance
        union all
        select title, arn, account_id, region, null as instance_id, db_instance_identifier from aws_rds_db_instance
      ) as resources
    order by
      title;
  EOQ
}

# With queries

query "ebs_volumes_for_resource" {
  sql = <<-EOQ
    select
      v.arn as volume_arn
    from
      aws_ec2_instance as i,
      jsonb_array_elements(block_device_mappings) as bd,
      aws_ebs_volume as v
    where
      i.arn = $1
      and v.volume_id = bd -> 'Ebs' ->> 'VolumeId'
      and i.region = v.region
      and i.account_id = v.account_id;
  EOQ
}

query "ec2_application_load_balancers_for_resource" {
  sql = <<-EOQ
    with resource_info as (
      select
        case 
          when i.arn is not null then i.instance_id
          when r.arn is not null then r.db_instance_identifier
        end as resource_id,
        split_part($1, ':', 5) as account_id,
        split_part($1, ':', 4) as region
      from
        aws_ec2_instance i
        full outer join aws_rds_db_instance r on i.arn = r.arn
      where
        coalesce(i.arn, r.arn) = $1
    ),
    target_groups as (
      select
        tg.target_health_descriptions,
        tg.load_balancer_arns
      from
        aws_ec2_target_group tg,
        resource_info ri
      where
        tg.account_id = ri.account_id
        and tg.region = ri.region
    )
    select distinct
      alb.arn as application_load_balancer_arn
    from
      resource_info ri
      cross join target_groups tg
      cross join jsonb_array_elements(tg.target_health_descriptions) as health_descriptions
      cross join jsonb_array_elements_text(tg.load_balancer_arns) as l
      join aws_ec2_application_load_balancer alb on l = alb.arn
    where
      health_descriptions -> 'Target' ->> 'Id' = ri.resource_id;
  EOQ
}

query "rds_db_instances_for_resource" {
  sql = <<-EOQ
    select
      arn as db_instance_arn
    from
      aws_rds_db_instance
    where
      arn = $1
    union
    select
      db_instance_arn
    from
      aws_rds_db_cluster,
      jsonb_array_elements_text(db_instance_arns) as db_instance_arn
    where
      arn = $1;
  EOQ
}

query "rds_db_clusters_for_resource" {
  sql = <<-EOQ
    select
      arn as cluster_arn
    from
      aws_rds_db_cluster
    where
      arn = $1;
  EOQ
}

query "vpc_vpcs_for_resource" {
  sql = <<-EOQ
    select
      vpc_id
    from
      aws_ec2_instance
    where
      arn = $1
    union
    select
      vpc_id
    from
      aws_rds_db_instance
    where
      arn = $1;
  EOQ
}

query "vpc_subnets_for_resource" {
  sql = <<-EOQ
    select
      subnet_id
    from
      aws_ec2_instance
    where
      arn = $1
    union
    select
      s
    from
      aws_rds_db_instance,
      jsonb_array_elements_text(subnets) as s
    where
      arn = $1;
  EOQ
}

query "vpc_security_groups_for_resource" {
  sql = <<-EOQ
    select
      sg ->> 'GroupId' as security_group_id
    from
      aws_ec2_instance,
      jsonb_array_elements(security_groups) as sg
    where
      arn = $1
    union
    select
      s
    from
      aws_rds_db_instance,
      jsonb_array_elements_text(vpc_security_groups) as s
    where
      arn = $1;
  EOQ
}

# Card queries

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

# Table queries

query "resource_overview" {
  sql = <<-EOQ
    select
      case 
        when i.arn is not null then 'EC2 Instance'
        when r.arn is not null then 'RDS Instance'
      end as "Resource Type",
      coalesce(i.instance_id, r.db_instance_identifier) as "Resource ID",
      coalesce(i.instance_state, r.status) as "Status",
      coalesce(i.instance_type, r.instance_class) as "Instance Type",
      coalesce(i.private_ip_address, r.endpoint_address) as "Private Address",
      coalesce(i.public_ip_address, r.publicly_accessible::text) as "Public Address",
      split_part($1, ':', 5) as "Account ID",
      split_part($1, ':', 4) as "Region"
    from
      aws_ec2_instance i
      full outer join aws_rds_db_instance r on i.arn = r.arn
    where
      coalesce(i.arn, r.arn) = $1;
  EOQ
}

query "resource_tags" {
  sql = <<-EOQ
    select
      tag ->> 'Key' as "Key",
      tag ->> 'Value' as "Value"
    from
      (
        select jsonb_array_elements(tags_src) as tag from aws_ec2_instance where arn = $1
        union all
        select jsonb_array_elements(tags_src) as tag from aws_rds_db_instance where arn = $1
      ) as tags
    order by
      tag ->> 'Key';
  EOQ
}

query "resource_security_groups" {
  sql = <<-EOQ
    select
      sg ->> 'GroupId' as "Group ID",
      sg ->> 'GroupName' as "Group Name"
    from
      aws_ec2_instance,
      jsonb_array_elements(security_groups) as sg
    where
      arn = $1
    union
    select
      vpc_security_groups[1] as "Group ID",
      sg.group_name as "Group Name"
    from
      aws_rds_db_instance db
      left join aws_vpc_security_group sg on sg.group_id = db.vpc_security_groups[1]
    where
      db.arn = $1;
  EOQ
}