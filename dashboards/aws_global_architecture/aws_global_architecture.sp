dashboard "aws_global_architecture" {
  title         = "AWS Global Architecture"
  documentation = file("./dashboards/aws_global_architecture/docs/aws_global_architecture.md")

  tags = merge(local.ec2_common_tags, {
    type = "Detail"
  })

  input "instance_arn" {
    title = "Select an instance:"
    query = aws_insights.ec2.query.ec2_instance_input
    width = 4
  }

  container {
    card {
      width = 2
      query = aws_insights.ec2.ec2_instance_detail.query.ec2_instance_status
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = aws_insights.ec2.query.ec2_instance_type
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = aws_insights.ec2.query.ec2_instance_total_cores_count
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = aws_insights.ec2.query.ec2_instance_public_access
      args  = [self.input.instance_arn.value]
    }

    card {
      width = 2
      query = aws_insights.ec2.query.ec2_instance_ebs_optimized
      args  = [self.input.instance_arn.value]
    }
  }

  with "ebs_volumes_for_ec2_instance" {
    query = aws_insights.ec2.query.ebs_volumes_for_ec2_instance
    args  = [self.input.instance_arn.value]
  }

  # ... (other 'with' blocks follow the same pattern)

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      # ... (node and edge definitions remain the same)
    }
  }

  container {
    container {
      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = aws_insights.ec2.query.ec2_instance_overview
        args  = [self.input.instance_arn.value]
      }

      table {
        title = "Tags"
        width = 6
        query = aws_insights.ec2.query.ec2_instance_tags
        args  = [self.input.instance_arn.value]
      }
    }

    container {
      width = 6

      table {
        title = "Block Device Mappings"
        query = aws_insights.ec2.query.ec2_instance_block_device_mapping
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
      query = aws_insights.ec2.query.ec2_instance_network_interfaces
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
      query = aws_insights.ec2.query.ec2_instance_security_groups
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
      query = aws_insights.ec2.query.ec2_instance_cpu_cores
      args  = [self.input.instance_arn.value]
    }
  }
}