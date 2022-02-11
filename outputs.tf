output "dev_machine_info" {
  value = {
    vpc_id = data.aws_vpc.default.id
    public_ipv4 = aws_eip.dev_machine_ip.public_ip
    efs_id = aws_efs_file_system.dev_efs.id
    access_point_data = aws_efs_access_point.dev_efs_main_ap.id
    access_point_docker = aws_efs_access_point.dev_efs_docker_ap.id
    ssh_access = "ssh ec2-user@${aws_eip.dev_machine_ip.public_ip}"
    bucket_name = aws_s3_bucket.dev_main_bucket.bucket
  }
}

output "roles" {
  value = {
    spot_fleet_role = aws_iam_role.dev_spot_fleet_role.arn,
    ec2_iam_role = aws_iam_role.dev_machine_role.arn,
    admin_role = aws_iam_role.dev_machine_admin_role.arn
  }
}

output "efs_mount" {
  value = {
    home = "sudo mount -t efs -o az=${var.dev_efs_az},tls,accesspoint=${aws_efs_access_point.dev_efs_main_ap.id} ${aws_efs_file_system.dev_efs.id}:/ /home/ec2-user"
    docker = "sudo mount -t efs -o az=${var.dev_efs_az},tls,accesspoint=${aws_efs_access_point.dev_efs_docker_ap.id} ${aws_efs_file_system.dev_efs.id}:/ /dockerlib"
  }
}
