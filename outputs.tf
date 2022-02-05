output "dev_machine_info" {
  value = {
    vpc_id = data.aws_vpc.default.id
    public_ipv4 = aws_eip.dev_machine_ip.public_ip
    efs_id = aws_efs_file_system.dev_efs.id
    access_point_data = aws_efs_access_point.dev_efs_main_ap.id
    access_point_docker = aws_efs_access_point.dev_efs_docker_ap.id
  }
}

output "efs_mount" {
  value = {
    home = "sudo mount -t efs -o az=ap-southeast-1a,tls,accesspoint=${aws_efs_access_point.dev_efs_main_ap.id} ${aws_efs_file_system.dev_efs.id}:/ /home/ec2-user"
    docker = "sudo mount -t efs -o az=ap-southeast-1a,tls,accesspoint=${aws_efs_access_point.dev_efs_docker_ap.id} ${aws_efs_file_system.dev_efs.id}:/ /home/ec2-user/dockerlib"
  }
}
