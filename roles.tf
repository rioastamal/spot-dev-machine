data "aws_caller_identity" "current" {}

resource "aws_iam_role" "dev_spot_fleet_role" {
  name = "EC2DevSpotFleetRole-${random_string.random.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
            Service = "spotfleet.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "dev_spot_fleet"
    policy = jsonencode({
    Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action: [
              "ec2:DescribeImages",
              "ec2:DescribeSubnets",
              "ec2:RequestSpotInstances",
              "ec2:TerminateInstances",
              "ec2:DescribeInstanceStatus",
              "ec2:CreateTags",
              "ec2:RunInstances"
          ],
          Resource = "*"
        },
        {
          Effect = "Allow",
          Action = "iam:PassRole",
          Condition = {
              StringEquals = {
                  "iam:PassedToService" = [
                    "ec2.amazonaws.com",
                    "ec2.amazonaws.com.cn"
                  ]
              }
          },
          Resource = "*"
        },
        {
          Effect = "Allow",
          Action = "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          Resource = "arn:aws:elasticloadbalancing:*:*:loadbalancer/*"
        },
        {
          Effect = "Allow",
          Action = "elasticloadbalancing:RegisterTargets",
          Resource = "arn:aws:elasticloadbalancing:*:*:*/*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "dev_machine_role" {
  name = "EC2DevMachineRole-${random_string.random.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        }
      }
    ]
  })

  inline_policy {
    name = "dev_s3_bucket"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "s3:ListBucket",
            "s3:CreateBucket",
            "s3:DeleteBucket"
          ]
          Resource = "arn:aws:s3:::${var.dev_bucket_name}"
        },
        {
          Effect = "Allow",
          Action = [
            "s3:*",
            "s3-object-lambda:*"
          ]
          Resource = "arn:aws:s3:::${var.dev_bucket_name}/*"
        }
      ]
    })
  }
  # S3

  inline_policy {
    name = "dev_ssm_access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "ssm:PutParameter",
            "ssm:DeleteParameter",
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:DeleteParameters"
          ]
          Resource = "arn:aws:ssm:${var.dev_machine_region}:${data.aws_caller_identity.current.account_id}:parameter/dev_*"
        },
        {
          Effect = "Allow",
          Action = [
            "ssm:DescribeParameters"
          ]
          Resource = "*"
        }
      ]
    })
  }
  # SSM

  inline_policy {
    name = "dev_ec2_access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ec2:AssociateAddress"
          ]
          Resource = [
            "arn:aws:ec2:${var.dev_machine_region}:${data.aws_caller_identity.current.account_id}:instance/*",
            "arn:aws:ec2:${var.dev_machine_region}:${data.aws_caller_identity.current.account_id}:elastic-ip/${aws_eip.dev_machine_ip.allocation_id}"
          ]
        }
      ]
    })
  }
  # EC2/EIP

}

# This role should be used only if you need access to all AWS Services
resource "aws_iam_role" "dev_machine_admin_role" {
  name = "EC2DevMachineAdminRole-${random_string.random.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        }
      }
    ]
  })

  inline_policy {
    name = "dev_admin_access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = "*"
          Resource = "*"
        }
      ]
    })
  }
  # admin
}