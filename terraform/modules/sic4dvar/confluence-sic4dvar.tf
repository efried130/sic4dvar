# Job Definition
resource "aws_batch_job_definition" "generate_batch_jd_sic4dvar" {
  name                  = "${var.prefix}-sic4dvar"
  type                  = "container"
  container_properties  = <<CONTAINER_PROPERTIES
  {
    "image": "${local.account_id}.dkr.ecr.us-west-2.amazonaws.com/${var.prefix}-sic4dvar",
    "executionRoleArn": "${data.aws_iam_role.exe_role.arn}",
    "jobRoleArn": "${data.aws_iam_role.job_role.arn}",
    "fargatePlatformConfiguration": { "platformVersion": "LATEST" },
    "logConfiguration": {
      "logDriver" : "awslogs",
      "options": {
        "awslogs-group" : "${data.aws_cloudwatch_log_group.cw_log_group.name}"
      }
    },
    "resourceRequirements": [
      {"type": "MEMORY", "value": "2048"},
      {"type": "VCPU", "value": "1"}
    ],
    "mountPoints": [
      {
        "sourceVolume": "input",
        "containerPath": "/mnt/data/input",
        "readOnly": true
      },
      {
        "sourceVolume": "flpe",
        "containerPath": "/mnt/data/output",
        "readOnly": false
      },
      {
        "sourceVolume": "logs",
        "containerPath": "/mnt/data/logs",
        "readOnly": false
      }      
    ],
    "volumes": [
      {
        "name": "input",
        "efsVolumeConfiguration": {
          "fileSystemId": "${data.aws_efs_file_system.aws_efs_input.file_system_id}",
          "rootDirectory": "/"
        }
      },
      {
        "name": "flpe",
        "efsVolumeConfiguration": {
          "fileSystemId": "${data.aws_efs_file_system.aws_efs_flpe.file_system_id}",
          "rootDirectory": "/sic4dvar"
        }
      },
      {
        "name": "logs",
        "efsVolumeConfiguration": {
          "fileSystemId": "${data.aws_efs_file_system.aws_efs_logs.file_system_id}",
          "rootDirectory": "/sic4dvar"
        }
      }
    ]
  }
  CONTAINER_PROPERTIES
  platform_capabilities = ["FARGATE"]
  propagate_tags        = true
  tags = { "job_definition": "${var.prefix}-sic4dvar" }
}
