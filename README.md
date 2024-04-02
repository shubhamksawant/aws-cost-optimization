# AWS Cost Optimization 

## Removing backup snapshots that isn't connected to any active EC2 instances

### Problem :
Sometimes, developers create EC2 instances with volumes attached to them by default. For backup purposes, these developers also create snapshots. However, when they no longer need the EC2 instance and decide to terminate it, they sometimes forget to delete the snapshots created for backup. As a result, they continue to incur costs for these unused snapshots, even though they are not actively using them.

### Solution :
We're using AWS to save money on storage costs. We made a Smart Lambda function that looks at our snapshots and our EC2 instances. If Lambda finds a snapshot that isn't connected to any active EC2 instances, it deletes it to save us money. This helps us keep our AWS costs down.


## starting and stopping EC2 Instance on Company Working Hours used by dev's for testing

### Problem Statement:
In many development environments, EC2 instances are utilized for testing purposes by developers. However, it's crucial to optimize costs by ensuring that these instances are only running during working hours when developers require them for testing. Manually starting and stopping these instances can be time-consuming and prone to errors. Therefore, there's a need for an automated solution to start and stop EC2 instances based on the company's working hours.

### Solution:
To address this problem, we can develop a Lambda function that starts and stops EC2 instances based on predefined working hours. Here's how the solution can be implemented.


## Deleting Elastic IP which are not attached to EC2 instance  

### Problem Statement:
In AWS environments, Elastic IPs (EIPs) are often provisioned but not always attached to EC2 instances. This can lead to unused resources and unnecessary costs. Manually identifying and deleting unattached EIPs is time-consuming and error-prone, especially in large environments with many resources. Therefore, there is a need for an automated solution to identify and delete unattached EIPs efficiently.

### Solution:
To address this problem, we propose the development of a Lambda function that automatically identifies and deletes unattached Elastic IPs in the AWS environment. Below is the solution outline:

