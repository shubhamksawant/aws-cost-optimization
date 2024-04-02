import boto3
import os

def lambda_handler(event, context):
    # Retrieve region from environment variable
    region = os.environ.get('REGION', 'us-east-1')  # Default to us-east-1 if not provided

    # Initialize EC2 client with specified region
    ec2_client = boto3.resource('ec2', region_name=region)

    # Get EC2 instances based on specified tags
    instances = ec2_client.instances.filter(Filters=[
       {'Name': 'tag:owner', 'Values': [os.environ['OWNER_TAG']]},
        {'Name': 'tag:purpose', 'Values': [os.environ['PURPOSE_TAG']]}
    ])
    print(instances)
    # Extract instance IDs
    instance_ids = [instance.id for instance in instances]

    # Print found EC2 instances
    print(f"Found {len(instance_ids)} EC2 instances:")
    for instance_id in instance_ids:
        print(f" - Instance ID: {instance_id}")

    # Get all Elastic IPs
    ec2_client = boto3.client('ec2', region_name=region)
    eips = ec2_client.describe_addresses()

    # Track if any cleanup action was taken
    cleanup_done = False

    # Print found Elastic IPs
    print(f"\nFound {len(eips['Addresses'])} Elastic IPs:")
    for eip in eips['Addresses']:
        if 'InstanceId' not in eip or eip['InstanceId'] not in instance_ids:
            print(f" - Elastic IP: {eip['PublicIp']} (Unattached)")
            # Release unattached Elastic IP
            ec2_client.release_address(AllocationId=eip['AllocationId'])
            print(f"   - Released unattached Elastic IP: {eip['PublicIp']}")
            cleanup_done = True

    # Return status based on cleanup action
    if cleanup_done:
        return {
            'statusCode': 200,
            'body': 'Elastic IPs cleaned up successfully'
        }
    else:
        # Check if no Elastic IPs or instances were found
        if len(eips['Addresses']) == 0:
            status_message = 'No Elastic IPs found'
        elif len(instances) == 0:
            status_message = 'No instances found matching specified tags'
        else:
            status_message = 'No unattached Elastic IPs found'
        
        return {
            'statusCode': 404,
            'body': status_message
        }
