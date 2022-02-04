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

  managed_policy_arns = [ 
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  ]

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
  # s3

  inline_policy {
    name = "dev_ssm_access"
		policy = jsonencode({
			Version = "2012-10-17"
			Statement = [
				{
          Effect = "Allow",
          Action = [
          	"ds:CreateComputer",
            "ds:DescribeDirectories",
            "logs:*",
            "ssm:*",
            "ec2messages:*"
          ]
          Resource = "*"
        },
				{
          Effect = "Allow",
          Action = [
            "iam:CreateServiceLinkedRole",
            "iam:DeleteServiceLinkedRole",
            "iam:GetServiceLinkedRoleDeletionStatus"
          ]
          Resource = "arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*"
          Condition = {
            "StringLike" = {
              "iam:AWSServiceName" = "ssm.amazonaws.com"
            }
          }
				},
				{
          Effect = "Allow",
          Action = [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"          
					]
          Resource = "*"
				},
			]
		})
  }
  # SSM

  inline_policy {
    name = "dev_efs"
		policy = jsonencode({
			Version = "2012-10-17"
			Statement = [
				{
          Effect = "Allow",
          Action = [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:CreateFileSystem",
                "elasticfilesystem:CreateMountTarget",
                "elasticfilesystem:CreateTags",
                "elasticfilesystem:CreateAccessPoint",
                "elasticfilesystem:CreateReplicationConfiguration",
                "elasticfilesystem:DeleteFileSystem",
                "elasticfilesystem:DeleteMountTarget",
                "elasticfilesystem:DeleteTags",
                "elasticfilesystem:DeleteAccessPoint",
                "elasticfilesystem:DeleteFileSystemPolicy",
                "elasticfilesystem:DeleteReplicationConfiguration",
                "elasticfilesystem:DescribeAccountPreferences",
                "elasticfilesystem:DescribeBackupPolicy",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:DescribeFileSystemPolicy",
                "elasticfilesystem:DescribeLifecycleConfiguration",
                "elasticfilesystem:DescribeMountTargets",
                "elasticfilesystem:DescribeMountTargetSecurityGroups",
                "elasticfilesystem:DescribeTags",
                "elasticfilesystem:DescribeAccessPoints",
                "elasticfilesystem:DescribeReplicationConfigurations",
                "elasticfilesystem:ModifyMountTargetSecurityGroups",
                "elasticfilesystem:PutAccountPreferences",
                "elasticfilesystem:PutBackupPolicy",
                "elasticfilesystem:PutLifecycleConfiguration",
                "elasticfilesystem:PutFileSystemPolicy",
                "elasticfilesystem:UpdateFileSystem",
                "elasticfilesystem:TagResource",
                "elasticfilesystem:UntagResource",
                "elasticfilesystem:ListTagsForResource",
                "elasticfilesystem:Backup",
                "elasticfilesystem:Restore",
                "kms:DescribeKey",
                "kms:ListAliases"          
					]
          Resource = "*"
				},
				{
          Effect = "Allow",
          Action = [
            "iam:CreateServiceLinkedRole"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "iam:AWSServiceName" = [ "elasticfilesystem.amazonaws.com" ]
            }
          }
				}
			]
		})
  }
  # EFS
}

