resource "aws_iam_role" "dev_machine_role" {
  name = "EC2DevMachineRole"

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
          Service = "vpc-flow-logs.amazonaws.com"
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
          Resource = "arn:aws:ssm:::parameter/dev_*"
        },
        {
          Effect = "Allow",
          Action = [
            "ssm:DescribeParameters"
          ]
          Resource = "*"
      ]
    })
  }
  # SSM
}

