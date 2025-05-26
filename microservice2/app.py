import boto3
import json
import schedule
import time

# SQS queue URL
sqs_queue_url = 'https://sqs.us-east-2.amazonaws.com/123456789012/my-queue'

# S3 bucket name
s3_bucket_name = 'my-bucket'

def pull_messages_from_sqs():
    sqs = boto3.client('sqs')
    response = sqs.receive_message(QueueUrl=sqs_queue_url, MaxNumberOfMessages=10)

    if 'Messages' in response:
        for message in response['Messages']:
            data = json.loads(message['Body'])
            s3 = boto3.client('s3')
            s3.put_object(Body=json.dumps(data), Bucket=s3_bucket_name, Key='path/to/object')

            # Delete message from SQS queue
            sqs.delete_message(QueueUrl=sqs_queue_url, ReceiptHandle=message['ReceiptHandle'])

schedule.every(1).minutes.do(pull_messages_from_sqs)  # Pull messages every 1 minute

while True:
    schedule.run_pending()