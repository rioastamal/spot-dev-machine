## About spot-dev-machine

The aim of this project is to simplify creation of an Amazon EC2 Spot instance which then can be used as development machine. The instance will use Amazon Linux 2 x86_64 AMI.

What is [Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/)? Amazon EC2 Spot Instances let you take advantage of unused EC2 capacity in the AWS cloud. Spot Instances are available at up to a 90% discount compared to On-Demand prices.

Spot Instances can be interrupted at anytime, so we will use Amazon EFS to store the data to make it persistent between each EC2 Spot lifecycle. This script will automatically make home directory persistent by re-mounting it to an Amazon EFS mount point.

ToC

- [Requirements](#requirements)
- [How to Run](#how-to-run)
- [Accessing EC2 Spot Instance](#accessing-ec2-spot-instance)
- [Amazon EFS Mount Location](#amazon-efs-mount-location)
- [Integrate with AWS Cloud9](#integrate-with-aws-cloud9)
- [FAQ](#faq)
    - [Will my data in home directory gone after instance terminated?](#will-my-data-in-home-directory-gone-after-instance-terminated)
    - [How do I terminate the instance?](#how-do-i-terminate-the-instance)
    - [How do I switch to Administrator role?](#how-do-i-switch-to-administrator-role)
    - [How do I run Docker?](#how-do-i-run-docker)
    - [What happen when my EC2 Spot interrupted?](#what-happen-when-my-ec2-spot-interrupted)
    - [Do I need to reconfigure my AWS Cloud9 after instance got interrupted?](#do-i-need-to-reconfigure-my-aws-cloud9-after-instance-got-interrupted)

## Requirements

To run this project what you needs are:

- an active AWS Account
- Terraform 1.x

## How to Run

Clone this repository or download archived version from GitHub.

```sh
$ git clone git@github.com:rioastamal/spot-dev-machine.git
```

Make sure you have already setup your [AWS credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) before running Terraform.

As part of the best practice, the security group only allows you to connect to instance via your IP address. So you need to export environment variable `TF_VAR_dev_my_ip`.

```sh
$ cd spot-dev-machine
$ export TF_VAR_dev_my_ip=YOUR_IP_ADDRESS/32
$ export TF_VAR_dev_bucket_name=YOUR_BUCKET_NAME
$ terraform apply
```

If you're OK with all the settings, proceed with `yes` response. After running the command it creates several AWS resources.

- Amazon EC2 Spot Instance (default to t3.micro)
- Amazon S3
- Amazon EFS
- AWS IAM roles
- AWS System Manager (Parameter Store)
- Elastic IP
- Security Group

During the instance initialization it runs user-data script that defined at `var.dev_user_data_url` which by default to [scripts/user-data.sh](https://raw.githubusercontent.com/rioastamal/spot-dev-machine/master/scripts/user-data.sh).

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
- Access point `/docker` (`root`) will be mounted to `/home/ec2-user/dockerlib`

Since directory /home/ec2-user is mounted using EFS, all the data will not lost when EC2 Spot is terminated.

Directory `/home/ec2-user/dockerlib` is used to replace `/var/lib/docker` which store all Docker related data.

## Integrate with AWS Cloud9

Make sure you have Node.js 12.x, you can install it using nvm.

```sh
$ nvm install 12
```

Then run AWS Cloud9 installer from this repository.

```sh
$ curl -s https://raw.githubusercontent.com/rioastamal/spot-dev-machine/master/scripts/install-cloud9.sh | bash
```

It will install lot of packages and it may takes couple of minutes. After installation is complete you may delete package which no longer needed.

```sh
$ sudo yum groupremove -y 'Development Tools'
```

Now go to AWS Cloud9 console and then create new SSH environment. Settings that have to be setup are:

- **User** - This is for SSH username, enter `ec2-user`
- **Host** - Enter your Elastic IP address
- **Port** - Leave `22` as the default 
- **Environment path** - Enter `/home/ec2-user`
- **Node.js binary path** - Path to your Node.js 12 binary e.g `/opt/nvm/versions/node/v12.22.10/bin/node`.

You need to add AWS Cloud9 public SSH key to your EC2 instance. Make sure you add it at `/home/ec2-user/.ssh/authorized_keys`.

## FAQ

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

Replace `YOUR_ACCOUNT_ID` your actual AWS account ID. Command above will output `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_SESSION_TOKEN` which temporarily can be used as Administrator credentials.

```sh
export AWS_ACCESS_KEY_ID=Some_random_string
export AWS_SECRET_ACCESS_KEY=Some_random_string
export AWS_SESSION_TOKEN=Very_long_random_string
```

### How do I run Docker?

Make sure the service is started using `systemctl`.

```sh
$ sudo systemctl start docker
$ sudo systemctl status docker
```

Now you can use Docker as usual.

### What happen when my EC2 Spot interrupted?

It should automatically get replaced by new instance once the unused capacity is available. It could be replaced in seconds, minutes or even longer because it depends on availability of the capacity.

Everything outside `/home/ec2-user` directory will be gone. Incudling all your softwares that you have installed using `yum`. In my opinion this is not a big deal since you can reinstall the software using the same command.

If you want to persist then you may copy or install the software to EFS under `/home/ec2-user`.

### Do I need to reconfigure my AWS Cloud9 after instance got interrupted?

No. AWS Cloud9 should be able to connect to new instance automatically since `~/.c9` directory is saved on Amazon EFS.