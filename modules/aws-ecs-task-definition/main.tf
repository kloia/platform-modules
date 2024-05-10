#------------------------------------------------------------------------------
# AWS ECS Task Execution Role
#------------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name                 = "${var.name_prefix}-ecs-task-execution-role"
  assume_role_policy   = file("${path.module}/files/iam/ecs_task_execution_iam_role.json")
  permissions_boundary = var.permissions_boundary
  tags                 = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:${var.iam_partition}:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_task_execution_role_custom_policy" {
  count       = length(var.ecs_task_execution_role_custom_policies)
  name        = "${var.name_prefix}-ecs-task-execution-role-custom-policy-${count.index}"
  description = "A custom policy for ${var.name_prefix}-ecs-task-execution-role IAM Role"
  policy      = var.ecs_task_execution_role_custom_policies[count.index]
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_custom_policy" {
  count      = length(var.ecs_task_execution_role_custom_policies)
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_role_custom_policy[count.index].arn
}

#------------------------------------------------------------------------------
# ECS Task Definition
#------------------------------------------------------------------------------
# Task Definition
resource "aws_ecs_task_definition" "td" {
  family = "${var.name_prefix}-td"
  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      cpu       = var.container_cpu
      memory    = var.container_memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_host_port
        }
      ]
    }
  ])
  task_role_arn      = var.task_role_arn == null ? aws_iam_role.ecs_task_execution_role.arn : var.task_role_arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  network_mode       = "awsvpc"
  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      expression = lookup(placement_constraints.value, "expression", null)
      type       = placement_constraints.value.type
    }
  }
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  requires_compatibilities = ["FARGATE"]
  dynamic "proxy_configuration" {
    for_each = var.proxy_configuration
    content {
      container_name = proxy_configuration.value.container_name
      properties     = lookup(proxy_configuration.value, "properties", null)
      type           = lookup(proxy_configuration.value, "type", null)
    }
  }
  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size == 0 ? [] : [var.ephemeral_storage_size]
    content {
      size_in_gib = var.ephemeral_storage_size
    }
  }
  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value.name

      host_path = lookup(volume.value, "host_path", null)

      dynamic "docker_volume_configuration" {
        for_each = lookup(volume.value, "docker_volume_configuration", [])
        content {
          autoprovision = lookup(docker_volume_configuration.value, "autoprovision", null)
          driver        = lookup(docker_volume_configuration.value, "driver", null)
          driver_opts   = lookup(docker_volume_configuration.value, "driver_opts", null)
          labels        = lookup(docker_volume_configuration.value, "labels", null)
          scope         = lookup(docker_volume_configuration.value, "scope", null)
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = lookup(volume.value, "efs_volume_configuration", [])
        content {
          file_system_id          = lookup(efs_volume_configuration.value, "file_system_id", null)
          root_directory          = lookup(efs_volume_configuration.value, "root_directory", null)
          transit_encryption      = lookup(efs_volume_configuration.value, "transit_encryption", null)
          transit_encryption_port = lookup(efs_volume_configuration.value, "transit_encryption_port", null)
          dynamic "authorization_config" {
            for_each = lookup(efs_volume_configuration.value, "authorization_config", [])
            content {
              access_point_id = lookup(authorization_config.value, "access_point_id", null)
              iam             = lookup(authorization_config.value, "iam", null)
            }
          }
        }
      }
    }
  }

  tags = var.tags
}

# TODO - Add this missing parameter
# inference_accelerator - (Optional) Configuration block(s) with Inference Accelerators settings. Detailed below.