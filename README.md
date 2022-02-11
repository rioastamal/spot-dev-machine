## About spot-dev-machine

The aim of this project is to simplify creation of an Amazon EC2 Spot instance which then can be used as development machine. The instance will use Amazon Linux 2 x86_64 AMI.

What is [Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/)? Amazon EC2 Spot Instances let you take advantage of unused EC2 capacity in the AWS cloud. Spot Instances are available at up to a 90% discount compared to On-Demand prices.

Spot Instances can be interrupted at anytime, so we will use Amazon EFS to store the data and make it persistent between each EC2 Spot lifecycle. This script will automatically make home directory persistent by re-mounting it to an Amazon EFS mount point.

Table of Contents:

- [Requirements](#requirements)
- [How to Run](#how-to-run)
- [Accessing EC2 Spot Instance](#accessing-ec2-spot-instance)
- [Amazon EFS Mount Location](#amazon-efs-mount-location)
- [Integrate with AWS Cloud9](#integrate-with-aws-cloud9)
- [FAQ](#faq)
    - [Why Amazon EFS is not mounted to my /home/ec2-user?](#why-amazon-efs-is-not-mounted-to-my-homeec2-user)
    - [Why do you use Amazon EFS instead of Amazon EBS?](#why-do-you-use-amazon-efs-instead-of-amazon-ebs)
    - [How do I know if Amazon EFS is successfully mounted?](#how-do-i-know-if-amazon-efs-is-successfully-mounted)
    - [Why do you use One Zone Storage for EFS?](#why-do-you-use-one-zone-storage-for-efs)
    - [How do I change variables in Terraform?](#how-do-i-change-variables-in-terraform)
    - [What variables that I need to change?](#what-variables-that-i-need-to-change)
    - [Will my data in home directory gone after instance terminated?](#will-my-data-in-home-directory-gone-after-instance-terminated)
    - [How do I terminate the instance?](#how-do-i-terminate-the-instance)
    - [How do I switch to Administrator role?](#how-do-i-switch-to-administrator-role)
    - [How do I run Docker?](#how-do-i-run-docker)
    - [What happen when my EC2 Spot interrupted?](#what-happen-when-my-ec2-spot-interrupted)
    - [Do I need to reconfigure my AWS Cloud9 after instance got interrupted?](#do-i-need-to-reconfigure-my-aws-cloud9-after-instance-got-interrupted)
- [Contributing](#contributing)
- [License](#license)

## Requirements

To run this project what you needs are:

- an active AWS Account
- Terraform 1.x

## How to Run

Clone this repository or download archived version from GitHub.

```sh
$ git clone git@github.com:rioastamal/spot-dev-machine.git
$ cd spot-dev-machine
```

Make sure you have already setup your [AWS credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) before running Terraform.

Create new Terraform variables file `terraform.tfvars` and define variables that you need to override from `variables.tf`. As an example I am using `ap-southeast-1` region.

```sh
$ cat > terraform.tfvars
dev_machine_region = "ap-southeast-1"
dev_efs_az = "ap-southeast-1a"
dev_ssh_public_key = "YOUR_SSH_PUBLIC_KEY"
dev_my_ip = "YOUR_IP_ADDRESS/32"
```

Hit combination of `CTRL+D` to save the file.

As part of the best practice, the security group only allows you to connect to instance via your IP address and from AWS Cloud9 IP address range (default to ap-southeast-1 region).

If everything is set you can continue by running `init` for the first time and then `apply`.

```sh
$ terraform init
$ terraform apply
```

You may review all the resources that going to be created, proceed with "yes" if you thing all is correct. 

After running the command it creates several AWS resources:

- Amazon EC2 Spot Instance (default to t3.micro)
- Amazon S3 bucket
- Amazon EFS
- AWS IAM roles
- AWS System Manager (Parameter Store)
- Elastic IP
- Security Group

During the instance initialization it runs user-data script that defined at `var.dev_user_data_url` which by default to [scripts/user-data.sh](https://raw.githubusercontent.com/rioastamal/spot-dev-machine/master/scripts/user-data.sh). If want to customize user-data script, you may change this to your own URL of custom script.

## Accessing EC2 Spot Instance

To access the development machine you can use SSH by connecting to it's Elastic IP address.

```sh
$ ssh ec2-user@ELASTIC_IP
```

There are several applications that installed by default via user-data init script. Here is the list:

- [AWS CLI v2](scripts/01-install-aws-cli-v2.auto-install.sh)
- [tmux](scripts/02-install-tmux.auto-install.sh)
- [nvm](scripts/03-install-nvm.auto-install.sh)
- [Docker](scripts/04-install-docker.auto-install.sh)

## Amazon EFS Mount Location

During the user-data init script the home directory will be remounted to use EFS. There are two access points: `/data` and `/docker`.

- Access point `/data` (`ec2-user`) will be mounted to `/home/ec2-user`
- Access point `/docker` (`root`) will be mounted to `/dockerlib`

Since directory /home/ec2-user is mounted using EFS, all the data will not lost when EC2 Spot is terminated.

Directory `/dockerlib` is used to replace `/var/lib/docker` which store all Docker related data.

## Integrate with AWS Cloud9

Make sure you have Node.js 12.x, you can install it using nvm.

```sh
$ nvm install 12
```

Then run AWS Cloud9 installer from this repository.

```sh
$ curl -s https://raw.githubusercontent.com/rioastamal/spot-dev-machine/master/scripts/install-cloud9.sh | bash
```

It will install lot of packages and it may take couple of minutes. After installation is complete you may delete installed packages which no longer needed.

```sh
$ sudo yum groupremove -y 'Development Tools'
```

Now go to AWS Cloud9 console and then create new SSH environment. Settings that have to be setup are:

- **User** - This is for SSH username, enter `ec2-user`
- **Host** - Enter your Elastic IP address
- **Port** - Leave `22` as the default 

You need to add AWS Cloud9 public SSH key to your EC2 instance. Make sure you add it at `/home/ec2-user/.ssh/authorized_keys`.

## FAQ

### Why Amazon EFS is not mounted to my /home/ec2-user?

Probably there was an error occured during the cloud init. Check the log at `/var/log/cloud-init-output.log` for more details.

You can also trying to re-run user-data script by running following command.

```sh
$ curl http://169.254.169.254/latest/user-data | sudo bash
```

### Why do you use Amazon EFS instead of Amazon EBS?

You can only attach Amazon EBS to EC2 instance in the same availability zone (AZ). This is the main drawback. 

When new EC2 Spot instance is launched it may use different AZ than the old one. If it happens, the EBS volume can not be attached to the new launched instance since it is in different AZ.

So storing data in the EBS is not suitable. That's the main reason why we choose Amazon EFS over EBS.

### How do I know if Amazon EFS is successfully mounted?

You can run following command.

```sh
$ sudo mount -t nfs4
```

It will output EFS access point and mount location.

### Why do you use One Zone Storage for EFS?

Simple. Because it's cheaper.

### How do I change variables in Terraform?

There are several ways you can change variables in Terraform. First option and does not require you to edit a file is using environment variable. Suppose you want change instance type which defined in variable `dev_instance_type`.

```sh
$ export TF_VAR_dev_instance_type=t3.large
$ terraform apply
```

Second option are using special file called `terraform.tfvars`. As an example you can create the file to override default values.

```
$ cat > terraform.tfvars
dev_instance_type = "t3.large"
dev_my_ip = "1.2.3.4/32"
# and others
```

You can find more details about using variables in Terraform at [here](https://www.terraform.io/language/values/variables).

### What variables that I need to change?

There are several variables which you may want to change for the first run: 

- `dev_machine_region`: Your preferred AWS region
- `dev_efs_az`: Preferred availability zone for Amazon EFS in selected region
- `dev_spot_price`: Maximum spot price, the price is different for every region. You should see the history or pricing page.
- `dev_my_ip`: Your computer IP address in format YOUR_IP/32

### Will my data in home directory gone after instance terminated?

No. Home directory `/home/ec2-user` is automatically mounted to EFS during OS boot so it should be safe when EC2 Spot terminated.

### How do I terminate the instance?

To terminate the instance you can use `destroy` with specific target to the EC2 Spot instance and Elastic IP to prevent cost.

```sh
$ terraform destroy --target=aws_instance.dev_ec2_spot \
--target=aws_eip.dev_machine_ip
```

### How do I terminate all the resources?

To prevent accidental removal of the Amazon EFS resources by default running `terraform destroy` will be denied. If you really want to terminate all the resources including the EFS you need to modify `main.tf` and set the lifecycle policy to `prevent_destroy = false`.

```tf
lifecycle {
  prevent_destroy = false
}
```

Save the file and run `terraform destroy`. Make sure you already backup your important files first.

### How do I switch to Administrator role?

Running an EC2 instance with Administrator role is a risk even it's a development machine. As part of security [best practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html#grant-least-privilege) the instance profile role `EC2DevMachineRole` only granted limited permissions. If you want to grant more permissions you can modify or attach new policy to the role. Do not forget to revoke the permissions when you do not need it.

The more secure way is to assume `EC2DevMachineAdminRole` to create temporary Administrator credentials that you can use inside your instance or app.

You may use your local machine or AWS CloudShell to run this command as user which have Administrator access.

```sh
$ aws sts assume-role --role-arn arn:aws:iam::YOUR_ACCOUNT_ID:role/EC2DevMachineAdminRole --role-session-name EC2TmpAdminRole | \
jq -r '.Credentials | "export AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nexport AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)\nexport AWS_SESSION_TOKEN=\(.SessionToken)"'
```

Tips: You can use `terraform output` command to get the role arn.

Replace `YOUR_ACCOUNT_ID` your actual AWS account ID. Command above will output `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_SESSION_TOKEN` which temporarily can be used as Administrator credentials.

```sh
export AWS_ACCESS_KEY_ID=Some_random_string
export AWS_SECRET_ACCESS_KEY=Some_random_string
export AWS_SESSION_TOKEN=Very_long_random_string
```

Now you can use those keys to access AWS services via AWS CLI or AWS SDK.

### How do I run Docker?

Make sure the service is started using `systemctl`.

```sh
$ sudo systemctl start docker
$ sudo systemctl status docker
```

Now you can use Docker as usual.

### What happen when my EC2 Spot interrupted?

It should automatically get replaced by new instance once the unused capacity is available. It could be replaced in seconds, minutes or even longer because it depends on availability of the capacity.

Everything outside `/home/ec2-user` and `/dockerlib` directory will be gone. Incudling all your softwares that you have installed using `yum`. In my opinion this is not a big deal since you can reinstall the software using the same command.

If you want to persist then you may copy or install the software to EFS under `/home/ec2-user`.

### Do I need to reconfigure my AWS Cloud9 after instance got interrupted?

No. AWS Cloud9 should be able to connect to new instance automatically since `~/.c9` directory is saved on Amazon EFS.

### I can not connect to the instance from AWS Cloud9, what's the problem?

Security group for SSH server in the EC2 instance only allows connection from values defined in `dev_my_ip` and `dev_cloud9_ips`. If you use AWS Cloud9 other than `ap-southeast-1` then you may need to change the value of dev_cloud9_ips.

To get list of IP address range for AWS Cloud9 you can refer to this [page](https://docs.aws.amazon.com/cloud9/latest/user-guide/ip-ranges.html).

## Contributing

Fork this repo and send me a PR. I am happy to review and merge it.

## License

This project is licensed under MIT License.