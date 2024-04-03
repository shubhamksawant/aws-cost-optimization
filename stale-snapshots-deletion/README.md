# AWS Cost Optimization 

## Removing backup snapshots that isn't connected to any active EC2 instances

### Problem :
Sometimes, developers create EC2 instances with volumes attached to them by default. For backup purposes, these developers also create snapshots. However, when they no longer need the EC2 instance and decide to terminate it, they sometimes forget to delete the snapshots created for backup. As a result, they continue to incur costs for these unused snapshots, even though they are not actively using them.

### Solution :
We're using AWS to save money on storage costs. We made a Smart Lambda function that looks at our snapshots and our EC2 instances. If Lambda finds a snapshot that isn't connected to any active EC2 instances, it deletes it to save us money. This helps us keep our AWS costs down.


Run following command to run the application
- clone the repo
- cd into folder
- run terraform init command
- run terraform plan command { aws_region(default region us-east-1)  tags can be provided as variable }
- #run terraform apply command to override default region use below command and update tags for ec2
- terraform apply -var aws_region=us-west-1 -auto-approve( to approve deployment automatically)
