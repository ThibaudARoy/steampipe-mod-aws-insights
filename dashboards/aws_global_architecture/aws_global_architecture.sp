dashboard "aws_global_architecture" {
  title         = "AWS Global Architecture"
  documentation = file("./dashboards/aws_global_architecture/docs/aws_global_architecture.md")

  tags = merge(local.ec2_common_tags, {
    type = "Detail"
  })

  input "instance_arn" {
    title = "Select an instance:"
    query = aws_insights.query.ec2_instance_input
    width = 4
  }

  container {
    card {
      width = 2
      query = aws_insights.query.ec2_instance_status
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = aws_insights.query.ec2_instance_type
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = aws_insights.query.ec2_instance_total_cores_count
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = aws_insights.query.ec2_instance_public_access
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = aws_insights.query.ec2_instance_ebs_optimized
      args  = [self.input.instance_arn.value]
    }
  }

  with "ebs_volumes_for_ec2_instance" {
    query = aws_insights.query.ebs_volumes_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  with "ec2_application_load_balancers_for_ec2_instance" {
    query = aws_insights.query.ec2_application_load_balancers_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  with "ec2_classic_load_balancers_for_ec2_instance" {
    query = aws_insights.query.ec2_classic_load_balancers_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  with "ec2_gateway_load_balancers_for_ec2_instance" {
    query = aws_insights.query.ec2_gateway_load_balancers_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  with "ec2_network_interfaces_for_ec2_instance" {
    query = aws_insights.query.ec2_network_interfaces_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  with "ec2_network_load_balancers_for_ec2_instance" {
    query = aws_insights.query.ec2_network_load_balancers_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  with "ec2_target_groups_for_ec2_instance" {
    query = aws_insights.query.ec2_target_groups_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  with "ecs_clusters_for_ec2_instance" {
    query = aws_insights.query.ecs_clusters_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  with "iam_roles_for_ec2_instance" {
    query = aws_insights.query.iam_roles_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  with "vpc_eips_for_ec2_instance" {
    query = aws_insights.query.vpc_eips_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  with "vpc_security_groups_for_ec2_instance" {
    query = aws_insights.query.vpc_security_groups_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  with "vpc_subnets_for_ec2_instance" {
    query = aws_insights.query.vpc_subnets_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  with "vpc_vpcs_for_ec2_instance" {
    query = aws_insights.query.vpc_vpcs_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.ebs_volume
        args = {
          ebs_volume_arns = with.ebs_volumes_for_ec2_instance.rows[*].volume_arn
        }
      }

      node {
        base = node.ec2_application_load_balancer
        args = {
          ec2_application_load_balancer_arns = with.ec2_application_load_balancers_for_ec2_instance.rows[*].application_load_balancer_arn
        }
      }

      node {
        base = node.ec2_autoscaling_group
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      node {
        base = node.ec2_classic_load_balancer
        args = {
          ec2_classic_load_balancer_arns = with.ec2_classic_load_balancers_for_ec2_instance.rows[*].classic_load_balancer_arn
        }
      }

      node {
        base = node.ec2_gateway_load_balancer
        args = {
          ec2_gateway_load_balancer_arns = with.ec2_gateway_load_balancers_for_ec2_instance.rows[*].gateway_load_balancer_arn
        }
      }

      node {
        base = node.ec2_instance
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      node {
        base = node.ec2_key_pair
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      node {
        base = node.ec2_network_interface
        args = {
          ec2_network_interface_ids = with.ec2_network_interfaces_for_ec2_instance.rows[*].network_interface_id
        }
      }

      node {
        base = node.ec2_network_load_balancer
        args = {
          ec2_network_load_balancer_arns = with.ec2_network_load_balancers_for_ec2_instance.rows[*].network_load_balancer_arn
        }
      }

      node {
        base = node.ec2_target_group
        args = {
          ec2_target_group_arns = with.ec2_target_groups_for_ec2_instance.rows[*].target_group_arn
        }
      }

      node {
        base = node.ecs_cluster
        args = {
          ecs_cluster_arns = with.ecs_clusters_for_ec2_instance.rows[*].cluster_arn
        }
      }

      node {
        base = node.iam_instance_profile
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      node {
        base = node.iam_role
        args = {
          iam_role_arns = with.iam_roles_for_ec2_instance.rows[*].role_arn
        }
      }

      node {
        base = node.vpc_eip
        args = {
          vpc_eip_arns = with.vpc_eips_for_ec2_instance.rows[*].eip_arn
        }
      }

      node {
        base = node.vpc_security_group
        args = {
          vpc_security_group_ids = with.vpc_security_groups_for_ec2_instance.rows[*].security_group_id
        }
      }

      node {
        base = node.vpc_subnet
        args = {
          vpc_subnet_ids = with.vpc_subnets_for_ec2_instance.rows[*].subnet_id
        }
      }

      node {
        base = node.vpc_vpc
        args = {
          vpc_vpc_ids = with.vpc_vpcs_for_ec2_instance.rows[*].vpc_id
        }
      }

      edge {
        base = edge.ec2_autoscaling_group_to_ec2_instance
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ec2_classic_load_balancer_to_ec2_instance
        args = {
          ec2_classic_load_balancer_arns = with.ec2_classic_load_balancers_for_ec2_instance.rows[*].classic_load_balancer_arn
        }
      }

      edge {
        base = edge.ec2_instance_to_ebs_volume
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ec2_instance_to_ec2_key_pair
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ec2_instance_to_ec2_network_interface
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ec2_instance_to_iam_instance_profile
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ec2_instance_to_vpc_security_group
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ec2_instance_to_vpc_subnet
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ec2_load_balancer_to_ec2_target_group
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.ec2_network_interface_to_vpc_eip
        args = {
          ec2_network_interface_ids = with.ec2_network_interfaces_for_ec2_instance.rows[*].network_interface_id
        }
      }

      edge {
        base = edge.ec2_target_group_to_ec2_instance
        args = {
          ec2_target_group_arns = with.ec2_target_groups_for_ec2_instance.rows[*].target_group_arn
        }
      }

      edge {
        base = edge.ecs_cluster_to_ec2_instance
        args = {
          ec2_instance_arns = [self.input.instance_arn.value]
        }
      }

      edge {
        base = edge.iam_instance_profile_to_iam_role
        args = {
          iam_role_arns = with.iam_roles_for_ec2_instance.rows[*].role_arn
        }
      }

      edge {
        base = edge.vpc_subnet_to_vpc_vpc
        args = {
          vpc_subnet_ids = with.vpc_subnets_for_ec2_instance.rows[*].subnet_id
        }
      }
    }
  }

  container {
    container {
      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = aws_insights.query.ec2_instance_overview
        args  = [self.input.instance_arn.value]
      }

      table {
        title = "Tags"
        width = 6
        query = aws_insights.query.ec2_instance_tags
        args  = [self.input.instance_arn.value]
      }
    }

    container {
      width = 6

      table {
        title = "Block Device Mappings"
        query = aws_insights.query.ec2_instance_block_device_mapping
        args  = [self.input.instance_arn.value]

        column "Volume ARN" {
          display = "none"
        }

        column "Volume ID" {
          href = "/aws_insights.dashboard.ebs_volume_detail?input.volume_arn={{.'Volume ARN' | @uri}}"
        }
      }
    }
  }

  container {
    width = 12

    table {
      title = "Network Interfaces"
      query = aws_insights.query.ec2_instance_network_interfaces
      args  = [self.input.instance_arn.value]

      column "VPC ID" {
        href = "/aws_insights.dashboard.vpc_detail?input.vpc_id={{ .'VPC ID' | @uri }}"
      }
    }
  }

  container {
    width = 6

    table {
      title = "Security Groups"
      query = aws_insights.query.ec2_instance_security_groups
      args  = [self.input.instance_arn.value]

      column "Group ID" {
        href = "/aws_insights.dashboard.vpc_security_group_detail?input.security_group_id={{.'Group ID' | @uri}}"
      }
    }
  }

  container {
    width = 6

    table {
      title = "CPU cores"
      query = aws_insights.query.ec2_instance_cpu_cores
      args  = [self.input.instance_arn.value]
    }
  }
}