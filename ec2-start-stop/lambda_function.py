import boto3
import os
import datetime

def lambda_handler(event, context):
    # Retrieve region from environment variable
    region = os.environ.get('REGION', 'us-east-1')  # Default to us-east-1 if not provided
    
    # Initialize EC2 resource client with specified region
    ec2 = boto3.resource('ec2', region_name=region)
    
    # Get current time
    current_time = datetime.datetime.now().time()
    
    # Retrieve tags from environment variables
    owner_tag = os.environ['OWNER_TAG']
    purpose_tag = os.environ['PURPOSE_TAG']
    
    # Get instances based on specified tags
    instances = ec2.instances.filter(Filters=[
        {'Name': 'tag:owner', 'Values': [owner_tag]},
        {'Name': 'tag:purpose', 'Values': [purpose_tag]}
    ])

    # Track if any cleanup action was taken
    start = False
    stop  = False

    # Extract instance IDs
    instance_ids = [instance.id for instance in instances]

    # Print found EC2 instances
    print(f"Found {len(instance_ids)} EC2 instances:")
    for instance_id in instance_ids:
        print(f" - Instance ID: {instance_id}")

    # Loop through instances
    for instance in instances:
        instance_id = instance.instance_id
        state = instance.state['Name']
        
        # Start instance during working hours
        if current_time >= datetime.time(9, 0) and current_time <= datetime.time(18, 0):
            if state == 'stopped':
                instance.start()
                print(f"Started instance: {instance_id}")
                stop = True

        # Stop instance outside working hours
        else:
            if state == 'running':
                instance.stop()
                print(f"Stopped instance: {instance_id}")
                start = True

    # Return status based on cleanup action
    if stop:
        return {
            'statusCode': 200,
            'body': 'instance Stopped successfully'
        }
    elif start:
         return {
            'statusCode': 200,
            'body': 'instance started successfully'
        }
   
    else:
            status_message = 'No instance found '
            return {
                'statusCode': 404,
                'body': status_message
            }

