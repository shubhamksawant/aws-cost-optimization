import boto3
import os

def lambda_handler(event, context):
    # Initialize EC2 client
    ec2_client = boto3.client('ec2')

    # Get EC2 instances based on specified tags
    instances = ec2_client.describe_instances(Filters=[
        {'Name': 'owner', 'Values': [os.environ['OWNER_TAG']]},
        {'Name': 'purpose', 'Values': [os.environ['PURPOSE_TAG']]}
    ])

    # Extract instance IDs
    instance_ids = [instance['InstanceId'] for reservation in instances['Reservations'] for instance in reservation['Instances']]

    # Get all Elastic IPs
    eips = ec2_client.describe_addresses()

    # Delete unattached Elastic IPs
    for eip in eips['Addresses']:
        if 'InstanceId' not in eip or eip['InstanceId'] not in instance_ids:
            ec2_client.release_address(AllocationId=eip['AllocationId'])
            print(f"Deleted unattached Elastic IP: {eip['PublicIp']}")

    return {
        'statusCode': 200,
        'body': 'Elastic IPs cleaned up successfully'
    }
