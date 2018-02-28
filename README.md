# aws-snapshot-recovery

This tool is best used in conjunction with [terraform-modle-ebs-backup](https://github.com/kronostechnologies/terraform-module-ebs-backup). However, it is not necessary to use this terraform module at all. Your aws snapshot only need two tags : one for the name and one for the date it was taken.

## Install
`make && make dev`

## Usage

```
usage: aws-snapshot-recovery [-h] [-d DATE] [-n NAME] [-r] [--dry-run] [-v] [--debug]
            [--filter-name-tagkey TAGNAME] [--filter-date-tagkey TAGNAME]
            [--ec2-security-group-id ID] [--ec2-subnet-id ID]
            [--ec2-instance-type TYPE] [--ssh-key-pair NAME]

Amazon Snapshot Recovery Tool

optional arguments:
  -h, --help            show this help message and exit
  -d DATE, --date DATE  date of the snapshot you are searching for
  -n NAME, --name NAME  name of the snapshot you are searching for
  -r, --recover         recover the given snapshot
  --dry-run             do not create any aws resource however, aws query are
                        still executed
  -v, --verbose         increase output verbosity
  --debug               greatly increase output verbosity
  --filter-name-tagkey TAGNAME
                        set the tag key to use when filtering with --name
  --filter-date-tagkey TAGNAME
                        set the tag key to use when filtering with --date
  --ec2-security-group-id ID
                        set the ec2 security group id
  --ec2-subnet-id ID    set the ec2 subnet id
  --ec2-instance-type TYPE
                        set the ec2 instance type
  --ssh-key-pair NAME   specify the ssh key pair to use
```

## Configuration
Configuration is set either via environment variable or a yaml file

### Environment variables
Environment variables are directly connected to their yaml configuration file counterpart and have _precedence_ over them.
#### AWS_SNAPSHOT_RECOVERY_FILTER_DATE_TAGKEY
Define the tag key used to filter on snapshot date. Default is "EbsBackup_DatetimeUTC"
#### AWS_SNAPSHOT_RECOVERY_FILTER_NAME_TAGKEY
Define the tag key used to filter on the snapshot name. Default is "Name".
#### AWS_SNAPSHOT_RECOVERY_SSH_KEY_PAIR
Define the ssh key pair to use when creating the ec2 instance. Default is the name of the current user.
#### AWS_SNAPSHOT_RECOVERY_EC2_SECURITY_GROUP_ID
Define the security group id. Default is the "default" security group.
#### AWS_SNAPSHOT_RECOVERY_EC2_SUBNET_ID
Define the ec2 subnet id. Default will use the default subnet of the default vpc.
 > If you specify a subnet id, it must exist in the specified availability zone
#### AWS_SNAPSHOT_RECOVERY_EC2_INSTANCE_TYPE
Define the ec2 instance type. Default is "t2-micro".

### Yaml
The yaml configuration file will be read from `~/.config/aws-snapshot-recovery.yaml`

Example yaml file :
```
filter_date_tagkey: EbsBackup_DatetimeUTC
filter_name_tagkey: Name
ssh_key_pair: username
ec2_security_group_id: 'sg-2afa5263'
ec2_subnet_id: 'subnet-39175'
ec2__instance_type: 't2-micro'
```
## AWS IAM Policy
Below is an example policy which fairly restrict the script permission.
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AwsSnapshotRecovery0",
            "Effect": "Allow",
            "Action": "ec2:TerminateInstances",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ec2:ResourceTag/AwsSnapshotRecovery": "true"
                }
            }
        },
        {
            "Sid": "AwsSnapshotRecovery1",
            "Effect": "Allow",
            "Action": "ec2:RunInstances",
            "Resource": "arn:aws:ec2:*::image/*",
            "Condition": {
                "StringEquals": {
                    "ec2:Owner": "379101102735"
                }
            }
        },
        {
            "Sid": "AwsSnapshotRecovery2",
            "Effect": "Allow",
            "Action": "ec2:CreateTags",
            "Resource": "arn:aws:ec2:*:*:instance/*",
            "Condition": {
                "ForAllValues:StringEquals": {
                    "aws:TagKeys": [
                        "AwsSnapshotRecovery",
                        "AwsSnapshotRecovery_SnapshotId",
                        "Name"
                    ]
                }
            }
        },
        {
            "Sid": "AwsSnapshotRecovery3",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:DescribeImageAttribute",
                "ec2:DescribeKeyPairs"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AwsSnapshotRecovery4",
            "Effect": "Allow",
            "Action": "ec2:RunInstances",
            "Resource": [
                "arn:aws:ec2:*:*:subnet/*",
                "arn:aws:ec2:*:*:key-pair/*",
                "arn:aws:ec2:*:*:instance/*",
                "arn:aws:ec2:*::snapshot/*",
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:security-group/*",
                "arn:aws:ec2:*:*:placement-group/*",
                "arn:aws:ec2:*:*:network-interface/*"
            ]
        },
        {
            "Sid": "AwsSnapshotRecovery5",
            "Effect": "Allow",
            "Action": "ec2:DescribeSnapshots",
            "Resource": "*",
            "Condition": {
                "ForAllValues:StringEquals": {
                    "aws:TagKeys": [
                        "EbsBackup_DatetimeUTC",
                        "Name"
                    ]
                }
            }
        }
    ]
}
```

 > If you change filter tag key configuration, you need to change the policy accordingly
