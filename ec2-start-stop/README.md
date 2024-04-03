# AWS Cost Optimization 

## Deleting Elastic IP which are not attached to EC2 instance  

### Problem Statement:
In AWS environments, Elastic IPs (EIPs) are often provisioned but not always attached to EC2 instances. This can lead to unused resources and unnecessary costs. Manually identifying and deleting unattached EIPs is time-consuming and error-prone, especially in large environments with many resources. Therefore, there is a need for an automated solution to identify and delete unattached EIPs efficiently.

### Solution:
To address this problem, we propose the development of a Lambda function that automatically identifies and deletes unattached Elastic IPs in the AWS environment. Below is the solution outline:


Run following command to run the application
- clone the repo
- run terraform init command
- run terraform plan command { aws_region(default region us-east-1)  & tag can be provided as variable }
- #run terraform apply command to override default region use below command and update tags to locate ec2 instances
- terraform apply -var aws_region=us-west-1 -var owner_tag=dev -var purpose_tag=test -auto-approve( to approve deployment automatically)


