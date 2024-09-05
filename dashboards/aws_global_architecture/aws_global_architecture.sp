dashboard "aws_global_architecture" {

  title         = "AWS Global Architecture"
  documentation = file("./dashboards/aws_global_architecture/docs/aws_global_architecture.md")

  tags = merge(local.ec2_common_tags, {
    type = "Detail"
  })

  input "global_instance_arn" {
    title = "Select an instance:"
    query = query.global_ec2_instance_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.global_ec2_instance_status
      args  = [self.input.global_instance_arn.value]
    }

    card {
      width = 2
      query = query.global_ec2_instance_type
      args  = [self.input.global_instance_arn.value]
    }

    card {
      width = 2
      query = query.global_ec2_instance_total_cores_count
      args  = [self.input.global_instance_arn.value]
    }

    card {
      width = 2
      query = query.global_ec2_instance_public_access
      args  = [self.input.global_instance_arn.value]
    }

    card {
      width = 2
      query = query.global_ec2_instance_ebs_optimized
      args  = [self.input.global_instance_arn.value]
    }
  }

  with "global_ebs_volumes_for_ec2_instance" {
    query = query.global_ebs_volumes_for_ec2_instance
    args  = [self.input.global_instance_arn.value]
  }

  with "global_ec2_application_load_balancers_for_ec2_instance" {
    query = query.global_ec2_application_load_balancers_for_ec2_instance
    args  = [self.input.global_instance_arn.value]
  }

  with "global_ec2_classic_load_balancers_for_ec2_instance" {
    query = query.global_ec2_classic_load_balancers_for_ec2_instance
    args  = [self.input.global_instance_arn.value]
  }

  with "global_ec2_gateway_load_balancers_for_ec2_instance" {
    query = query.global_ec2_gateway_load_balancers_for_ec2_instance
    args  = [self.input.global_instance_arn.value]
  }

  with "global_ec2_network_interfaces_for_ec2_instance" {
    query = query.global_ec2_network_interfaces_for_ec2_instance
    args  = [self.input.global_instance_arn.value]
  }

  with "global_ec2_network_load_balancers_for_ec2_instance" {
    query = query.global_ec2_network_load_balancers_for_ec2_instance
    args  = [self.input.global_instance_arn.value]
  }

  with "global_ec2_target_groups_for_ec2_instance" {
    query = query.global_ec2_target_groups_for_ec2_instance
    args  = [self.input.global_instance_arn.value]
  }

  with "global_ecs_clusters_for_ec2_instance" {
    query = query.global_ecs_clusters_for_ec2_instance
    args  = [self.input.global_instance_arn.value]
  }

  with "global_iam_roles_for_ec2_instance" {
    query = query.global_iam_roles_for_ec2_instance
    args  = [self.input.global_instance_arn.value]
  }

  with "global_vpc_eips_for_ec2_instance" {
    query = query.global_vpc_eips_for_ec2_instance
    args  = [self.input.global_instance_arn.value]
  }

  with "global_vpc_security_groups_for_ec2_instance" {
    query = query.global_vpc_security_groups_for_ec2_instance
    args  = [self.input.global_instance_arn.value]
  }

  with "global_vpc_subnets_for_ec2_instance" {
    query = query.global_vpc_subnets_for_ec2_instance
    args  = [self.input.global_instance_arn.value]
  }

  with "global_vpc_vpcs_for_ec2_instance" {
    query = query.global_vpc_vpcs_for_ec2_instance
    args  = [self.input.global_instance_arn.value]
  }

  container {

    graph {

      title     = "Global Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.global_ebs_volume
        args = {
          global_ebs_volume_arns = with.global_ebs_volumes_for_ec2_instance.rows[*].volume_arn
        }
      }

      node {
        base = node.global_ec2_application_load_balancer
        args = {
          global_ec2_application_load_balancer_arns = with.global_ec2_application_load_balancers_for_ec2_instance.rows[*].application_load_balancer_arn
        }
      }

      node {
        base = node.global_ec2_autoscaling_group
        args = {
          global_ec2_instance_arns = [self.input.global_instance_arn.value]
        }
      }

      node {
        base = node.global_ec2_classic_load_balancer
        args = {
          global_ec2_classic_load_balancer_arns = with.global_ec2_classic_load_balancers_for_ec2_instance.rows[*].classic_load_balancer_arn
        }
      }

      node {
        base = node.global_ec2_gateway_load_balancer
        args = {
          global_ec2_gateway_load_balancer_arns = with.global_ec2_gateway_load_balancers_for_ec2_instance.rows[*].gateway_load_balancer_arn
        }
      }

      node {
        base = node.global_ec2_instance
        args = {
          global_ec2_instance_arns = [self.input.global_instance_arn.value]
        }
      }

      node {
        base = node.global_ec2_key_pair
        args = {
          global_ec2_instance_arns = [self.input.global_instance_arn.value]
        }
      }

      node {
        base = node.global_ec2_network_interface
        args = {
          global_ec2_network_interface_ids = with.global_ec2_network_interfaces_for_ec2_instance.rows[*].network_interface_id
        }
      }

      node {
        base = node.global_ec2_network_load_balancer
        args = {
          global_ec2_network_load_balancer_arns = with.global_ec2_network_load_balancers_for_ec2_instance.rows[*].network_load_balancer_arn
        }
      }

      node {
        base = node.global_ec2_target_group
        args = {
          global_ec2_target_group_arns = with.global_ec2_target_groups_for_ec2_instance.rows[*].target_group_arn
        }
      }

      node {
        base = node.global_ecs_cluster
        args = {
          global_ecs_cluster_arns = with.global_ecs_clusters_for_ec2_instance.rows[*].cluster_arn
        }
      }

      node {
        base = node.global_iam_instance_profile
        args = {
          global_ec2_instance_arns = [self.input.global_instance_arn.value]
        }
      }

      node {
        base = node.global_iam_role
        args = {
          global_iam_role_arns = with.global_iam_roles_for_ec2_instance.rows[*].role_arn
        }
      }

      node {
        base = node.global_vpc_eip
        args = {
          global_vpc_eip_arns = with.global_vpc_eips_for_ec2_instance.rows[*].eip_arn
        }
      }

      node {
        base = node.global_vpc_security_group
        args = {
          global_vpc_security_group_ids = with.global_vpc_security_groups_for_ec2_instance.rows[*].security_group_id
        }
      }

      node {
        base = node.global_vpc_subnet
        args = {
          global_vpc_subnet_ids = with.global_vpc_subnets_for_ec2_instance.rows[*].subnet_id
        }
      }

      node {
        base = node.global_vpc_vpc
        args = {
          global_vpc_vpc_ids = with.global_vpc_vpcs_for_ec2_instance.rows[*].vpc_id
        }
      }

      edge {
        base = edge.global_ec2_autoscaling_group_to_ec2_instance
        args = {
          global_ec2_instance_arns = [self.input.global_instance_arn.value]
        }
      }

      edge {
        base = edge.global_ec2_classic_load_balancer_to_ec2_instance
        args = {
          global_ec2_classic_load_balancer_arns = with.global_ec2_classic_load_balancers_for_ec2_instance.rows[*].classic_load_balancer_arn
        }
      }

      edge {
        base = edge.global_ec2_instance_to_ebs_volume
        args = {
          global_ec2_instance_arns = [self.input.global_instance_arn.value]
        }
      }

      edge {
        base = edge.global_ec2_instance_to_ec2_key_pair
        args = {
          global_ec2_instance_arns = [self.input.global_instance_arn.value]
        }
      }

      edge {
        base = edge.global_ec2_instance_to_ec2_network_interface
        args = {
          global_ec2_instance_arns = [self.input.global_instance_arn.value]
        }
      }

      edge {
        base = edge.global_ec2_instance_to_iam_instance_profile
        args = {
          global_ec2_instance_arns = [self.input.global_instance_arn.value]
        }
      }

      edge {
        base = edge.global_ec2_instance_to_vpc_security_group
        args = {
          global_ec2_instance_arns = [self.input.global_instance_arn.value]
        }
      }

      edge {
        base = edge.global_ec2_instance_to_vpc_subnet
        args = {
          global_ec2_instance_arns = [self.input.global_instance_arn.value]
        }
      }

      edge {
        base = edge.global_ec2_load_balancer_to_ec2_target_group
        args = {
          global_ec2_instance_arns = [self.input.global_instance_arn.value]
        }
      }

      edge {
        base = edge.global_ec2_network_interface_to_vpc_eip
        args = {
          global_ec2_network_interface_ids = with.global_ec2_network_interfaces_for_ec2_instance.rows[*].network_interface_id
        }
      }

      edge {
        base = edge.global_ec2_target_group_to_ec2_instance
        args = {
          global_ec2_target_group_arns = with.global_ec2_target_groups_for_ec2_instance.rows[*].target_group_arn
        }
      }

      edge {
        base = edge.global_ecs_cluster_to_ec2_instance
        args = {
          global_ec2_instance_arns = [self.input.global_instance_arn.value]
        }
      }

      edge {
        base = edge.global_iam_instance_profile_to_iam_role
        args = {
          global_iam_role_arns = with.global_iam_roles_for_ec2_instance.rows[*].role_arn
        }
      }

      edge {
        base = edge.global_vpc_subnet_to_vpc_vpc
        args = {
          global_vpc_subnet_ids = with.global_vpc_subnets_for_ec2_instance.rows[*].subnet_id
        }
      }

    }

  }

  container {

    container {
      width = 6

      table {
        title = "Global Overview"
        type  = "line"
        width = 6
        query = query.global_ec2_instance_overview
        args  = [self.input.global_instance_arn.value]

      }

      table {
        title = "Global Tags"
        width = 6
        query = query.global_ec2_instance_tags
        args  = [self.input.global_instance_arn.value]
      }
    }

    container {
      width = 6

      table {
        title = "Global Block Device Mappings"
        query = query.global_ec2_instance_block_device_mapping
        args  = [self.input.global_instance_arn.value]

        column "Volume ARN" {
          display = "none"
        }

        column "Volume ID" {
          href = "/aws_insights.dashboard.global_ebs_volume_detail?input.volume_arn={{.'Volume ARN' | @uri}}"
        }
      }
    }

  }

  container {
    width = 12

    table {
      title = "Global Network Interfaces"
      query = query.global_ec2_instance_network_interfaces
      args  = [self.input.global_instance_arn.value]

      column "VPC ID" {
        href = "/aws_insights.dashboard.global_vpc_detail?input.vpc_id={{ .'VPC ID' | @uri }}"
      }
    }

  }

  container {
    width = 6

    table {
      title = "Global Security Groups"
      query = query.global_ec2_instance_security_groups
      args  = [self.input.global_instance_arn.value]

      column "Group ID" {
        href = "/aws_insights.dashboard.global_vpc_security_group_detail?input.security_group_id={{.'Group ID' | @uri}}"
      }
    }

  }

  container {
    width = 6

    table {
      title = "Global CPU cores"
      query = query.global_ec2_instance_cpu_cores
      args  = [self.input.global_instance_arn.value]
    }

  }

}

# Input queries

query "global_ec2_instance_input" {
  sql = <<-EOQ
    select
      title as label,
      arn as value,
      json_build_object(
        'account_id', account_id,
        'region', region,
        'instance_id', instance_id
      ) as tags
    from
      aws_ec2_instance
    order by
      title;
  EOQ
}

# With queries

query "global_ebs_volumes_for_ec2_instance" {
  sql = <<-EOQ
    with ec2_instances as (
      select
        arn,
        block_device_mappings,
        region,
        account_id
      from
        aws_ec2_instance
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
        and arn = $1
      order by
        arn,
        region,
        account_id
    ),
    ebs_volumes as (
      select
        arn,
        volume_id,
        region,
        account_id
      from
        aws_ebs_volume
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
      order by
        volume_id,
        region,
        account_id
    )
    select
      v.arn as volume_arn
    from
      ec2_instances as i,
      jsonb_array_elements(block_device_mappings) as bd,
      ebs_volumes as v
    where
      v.volume_id = bd -> 'Ebs' ->> 'VolumeId';
  EOQ
}

query "global_ec2_application_load_balancers_for_ec2_instance" {
  sql = <<-EOQ
    with aws_ec2_instances as (
      select
        instance_id,
        region,
        account_id,
        arn
      from
        aws_ec2_instance
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
        and arn = $1
    ),
    aws_ec2_target_groups as (
      select
        target_health_descriptions,
        load_balancer_arns
      from
        aws_ec2_target_group
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
    ),
    aws_ec2_application_load_balancers as (
      select
        arn
      from
        aws_ec2_application_load_balancer
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
    )
    select
      distinct lb.arn as application_load_balancer_arn
    from
      aws_ec2_instances as i,
      aws_ec2_target_groups as target,
      jsonb_array_elements(target.target_health_descriptions) as health_descriptions,
      jsonb_array_elements_text(target.load_balancer_arns) as l,
      aws_ec2_application_load_balancers as lb
    where
      health_descriptions -> 'Target' ->> 'Id' = i.instance_id
      and l = lb.arn;
  EOQ
}

query "global_ec2_classic_load_balancers_for_ec2_instance" {
  sql = <<-EOQ
    with aws_ec2_instances as (
      select
        instance_id,
        account_id,
        region
      from
        aws_ec2_instance
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
        and arn = $1
    ),
    aws_ec2_classic_load_balancers as (
      select
        arn,
        instances,
        region,
        account_id
      from
        aws_ec2_classic_load_balancer
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
    )
    select
      distinct clb.arn as classic_load_balancer_arn
    from
      aws_ec2_classic_load_balancers as clb,
      jsonb_array_elements(clb.instances) as instance,
      aws_ec2_instances as i
    where
      instance ->> 'InstanceId' = i.instance_id;
  EOQ
}

query "global_ec2_gateway_load_balancers_for_ec2_instance" {
  sql = <<-EOQ
    with aws_ec2_instances as (
      select
        arn,
        instance_id,
        account_id,
        region
      from
        aws_ec2_instance
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
        and arn = $1
    ),
    aws_ec2_target_groups as (
      select
        target_health_descriptions,
        load_balancer_arns,
        account_id,
        region
      from
        aws_ec2_target_group
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
    ),
    aws_ec2_gateway_load_balancers as (
      select
        arn,
        account_id,
        region
      from
        aws_ec2_gateway_load_balancer
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
    )
    select
      distinct lb.arn as gateway_load_balancer_arn
    from
      aws_ec2_instances as i,
      aws_ec2_target_groups as target,
      jsonb_array_elements(target.target_health_descriptions) as health_descriptions,
      jsonb_array_elements_text(target.load_balancer_arns) as l,
      aws_ec2_gateway_load_balancers as lb
    where
      health_descriptions -> 'Target' ->> 'Id' = i.instance_id
      and l = lb.arn;
  EOQ
}

query "global_ec2_network_interfaces_for_ec2_instance" {
  sql = <<-EOQ
    select
      network_interface ->> 'NetworkInterfaceId' as network_interface_id
    from
      aws_ec2_instance as i,
      jsonb_array_elements(network_interfaces) as network_interface
    where
      i.arn = $1
      and i.region = split_part($1, ':', 4)
      and i.account_id = split_part($1, ':', 5);
  EOQ
}

query "global_ec2_network_load_balancers_for_ec2_instance" {
  sql = <<-EOQ
    with aws_ec2_instances as (
      select
        arn,
        instance_id,
        account_id,
        region
      from
        aws_ec2_instance
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
        and arn = $1
    ),
    aws_ec2_target_groups as (
      select
        target_health_descriptions,
        load_balancer_arns,
        account_id,
        region
      from
        aws_ec2_target_group
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
    ),
    aws_ec2_network_load_balancers as (
      select
        arn,
        account_id,
        region
      from
        aws_ec2_network_load_balancer
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
    )
    select
      distinct lb.arn as gateway_load_balancer_arn
    from
      aws_ec2_instances as i,
      aws_ec2_target_groups as target,
      jsonb_array_elements(target.target_health_descriptions) as health_descriptions,
      jsonb_array_elements_text(target.load_balancer_arns) as l,
      aws_ec2_network_load_balancers as lb
    where
      health_descriptions -> 'Target' ->> 'Id' = i.instance_id
      and l = lb.arn;
  EOQ
}

query "global_ec2_target_groups_for_ec2_instance" {
  sql = <<-EOQ
    with aws_ec2_instances as (
      select
        instance_id,
        account_id,
        region
      from
        aws_ec2_instance
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
        and arn = $1
    ),
    aws_ec2_target_groups as (
      select
        target_group_arn,
        target_health_descriptions,
        account_id,
        region
      from
        aws_ec2_target_group
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
    )
    select
      target.target_group_arn
    from
      aws_ec2_instances as i,
      aws_ec2_target_groups as target,
      jsonb_array_elements(target.target_health_descriptions) as health_descriptions
    where
      health_descriptions -> 'Target' ->> 'Id' = i.instance_id;
  EOQ
}

query "global_ecs_clusters_for_ec2_instance" {
  sql = <<-EOQ
    with aws_ec2_instances as (
      select
        instance_id,
        account_id,
        region
      from
        aws_ec2_instance
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
        and arn = $1
    ),
    aws_ecs_container_instances as (
      select
        ec2_instance_id,
        cluster_arn,
        account_id,
        region
      from
        aws_ecs_container_instance
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
    ),
    aws_ecs_clusters as (
      select
        cluster_arn,
        account_id,
        region
      from
        aws_ecs_cluster
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
    )
    select
      distinct cluster.cluster_arn as cluster_arn
    from
      aws_ec2_instances as i,
      aws_ecs_container_instances as ci,
      aws_ecs_clusters as cluster
    where
      ci.ec2_instance_id = i.instance_id
      and ci.cluster_arn = cluster.cluster_arn;
  EOQ
}

query "global_iam_roles_for_ec2_instance" {
  sql = <<-EOQ
    with aws_ec2_instances as (
      select
        instance_id,
        iam_instance_profile_arn,
        account_id,
        region
      from
        aws_ec2_instance
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
        and arn = $1
    ),
    aws_iam_roles as (
      select
        instance_profile_arns,
        arn,
        account_id,
        region
      from
        aws_iam_role
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
    )
    select
      distinct r.arn as role_arn
    from
      aws_ec2_instances as i,
      aws_iam_roles as r,
      jsonb_array_elements_text(instance_profile_arns) as instance_profile
    where
      instance_profile = i.iam_instance_profile_arn;
  EOQ
}

query "global_vpc_eips_for_ec2_instance" {
  sql = <<-EOQ
    with aws_ec2_instances as (
      select
        instance_id,
        account_id,
        region
      from
        aws_ec2_instance
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
        and arn = $1
    ),
    aws_vpc_eips as (
      select
        instance_id,
        arn,
        account_id,
        region
      from
        aws_vpc_eip
      where
        account_id = split_part($1, ':', 5)
        and region = split_part($1, ':', 4)
    )
    select
      e.arn as eip_arn
    from
      aws_vpc_eips as e,
      aws_ec2_instances as i
    where
      e.instance_id = i.instance_id;
  EOQ
}

query "global_vpc_security_groups_for_ec2_instance" {
  sql = <<-EOQ
    select
      sg ->> 'GroupId' as security_group_id
    from
      aws_ec2_instance as i,
      jsonb_array_elements(security_groups) as sg
    where
      i.account_id = split_part($1, ':', 5)
      and i.region = split_part($1, ':', 4)
      and arn = $1;
  EOQ
}

query "global_vpc_subnets_for_ec2_instance" {
  sql = <<-EOQ
    select
      subnet_id as subnet_id
    from
      aws_ec2_instance as i
    where
      i.account_id = split_part($1, ':', 5)
      and i.region = split_part($1, ':', 4)
      and arn = $1;
  EOQ
}

query "global_vpc_vpcs_for_ec2_instance" {
  sql = <<-EOQ
    select
      vpc_id as vpc_id
    from
      aws_ec2_instance
    where
      aws_ec2_instance.account_id = split_part($1, ':', 5)
      and aws_ec2_instance.region = split_part($1, ':', 4)
      and arn = $1;
  EOQ
}

# Card queries

query "global_ec2_instance_status" {
  sql = <<-EOQ
    select
      'Status' as label,
      initcap(instance_state) as value
    from
      aws_ec2_instance
    where
      account_id = split_part($1, ':', 5)
      and region = split_part($1, ':', 4)
      and arn = $1;
  EOQ
}

query "global_ec2_instance_type" {
  sql = <<-EOQ
    select
      'Type' as label,
      instance_type as value
    from
      aws_ec2_instance
    where
      account_id = split_part($1, ':', 5)
      and region = split_part($1, ':', 4)
      and arn = $1;
  EOQ
}
query "global_ec2_instance_total_cores_count" {
  sql = <<-EOQ
    select
      'Total Cores' as label,
      sum(cpu_options_core_count) as value
    from
      aws_ec2_instance
    where
      account_id = split_part($1, ':', 5)
      and region = split_part($1, ':', 4)
      and arn = $1;
  EOQ
}

query "global_ec2_instance_public_access" {
  sql = <<-EOQ
    select
      'Public IP Address' as label,
      case when public_ip_address is null then 'Disabled' else host(public_ip_address) end as value,
      case when public_ip_address is null then 'ok' else 'alert' end as type
    from
      aws_ec2_instance
    where
      account_id = split_part($1, ':', 5)
      and region = split_part($1, ':', 4)
      and arn = $1;
  EOQ
}

query "global_ec2_instance_ebs_optimized" {
  sql = <<-EOQ
    select
      'EBS Optimized' as label,
      case when ebs_optimized then 'Enabled' else 'Disabled' end as value,
      case when ebs_optimized then 'ok' else 'alert' end as type
    from
      aws_ec2_instance
    where
      account_id = split_part($1, ':', 5)
      and region = split_part($1, ':', 4)
      and arn = $1;
  EOQ
}

# Misc queries

query "global_ec2_instance_overview" {
  sql = <<-EOQ
    select
      tags ->> 'Name' as "Name",
      instance_id as "Instance ID",
      launch_time as "Launch Time",
      title as "Title",
      region as "Region",
      account_id as "Account ID",
      arn as "ARN"
    from
      aws_ec2_instance
    where
      arn = $1
      and region = split_part($1, ':', 4)
      and account_id = split_part($1, ':', 5);
  EOQ
}

query "global_ec2_instance_tags" {
  sql = <<-EOQ
    select
      tag ->> 'Key' as "Key",
      tag ->> 'Value' as "Value"
    from
      aws_ec2_instance,
      jsonb_array_elements(tags_src) as tag
    where
      arn = $1
      and account_id = split_part($1, ':', 5)
    order by
      tag ->> 'Key';
    EOQ
}

query "global_ec2_instance_block_device_mapping" {
  sql = <<-EOQ
    with volume_details as (
    select
      p -> 'Ebs' ->> 'VolumeId'  as "Volume ID",
      p ->> 'DeviceName'  as "Device Name",
      p -> 'Ebs' ->> 'AttachTime' as "Attach Time",
      p -> 'Ebs' ->> 'DeleteOnTermination' as "Delete On Termination",
      p -> 'Ebs' ->> 'Status'  as "Status",
      arn
    from
      aws_ec2_instance,
      jsonb_array_elements(block_device_mappings) as p
    where
      arn = $1
    )
    select
      "Volume ID",
      "Device Name",
      "Attach Time",
      "Delete On Termination",
      "Status",
      v.arn as "Volume ARN"
    from
      volume_details as vd
      left join aws_ebs_volume v on v.volume_id = vd."Volume ID"
    where
      v.volume_id in (select "Volume ID" from volume_details)
  EOQ
}

query "global_ec2_instance_security_groups" {
  sql = <<-EOQ
    select
      p ->> 'GroupId'  as "Group ID",
      p ->> 'GroupName' as "Group Name"
    from
      aws_ec2_instance,
      jsonb_array_elements(security_groups) as p
    where
      region = split_part($1, ':', 4)
      and account_id = split_part($1, ':', 5)
      and arn = $1;
  EOQ
}

query "global_ec2_instance_network_interfaces" {
  sql = <<-EOQ
    select
      p ->> 'NetworkInterfaceId' as "Network Interface ID",
      p ->> 'InterfaceType' as "Interface Type",
      ips -> 'Association' ->> 'PublicIp' as "Public IP Address",
      ips ->> 'PrivateIpAddress' as "Private IP Address",
      p ->> 'Status' as "Status",
      p ->> 'SubnetId' as "Subnet ID",
      p ->> 'VpcId' as "VPC ID"
    from
      aws_ec2_instance,
      jsonb_array_elements(network_interfaces) as p,
      jsonb_array_elements(p -> 'PrivateIpAddresses') as ips
    where
      region = split_part($1, ':', 4)
      and account_id = split_part($1, ':', 5)
      and arn = $1;
  EOQ
}

query "global_ec2_instance_cpu_cores" {
  sql = <<-EOQ
    select
      cpu_options_core_count  as "CPU Options Core Count",
      cpu_options_threads_per_core  as "CPU Options Threads Per Core"
    from
      aws_ec2_instance
    where
      region = split_part($1, ':', 4)
      and account_id = split_part($1, ':', 5)
      and arn = $1;
  EOQ
}