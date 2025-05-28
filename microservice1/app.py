import http.server
import json
import boto3
import datetime

# Load token from SSM Parameter Store
ssm = boto3.client('ssm')
token = ssm.get_parameter(Name='token')['Parameter']['Value']

# SQS queue URL
sqs_queue_url = 'https://sqs.us-east-2.amazonaws.com/123456789012/my-queue'

class RequestHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        body = self.rfile.read(content_length)
        data = json.loads(body)

        # Token validation
        if data['token'] != token:
            self.send_response(401)
            self.end_headers()
            self.wfile.write(b'Invalid token')
            return

        # Date validity check
        try:
            timestream = int(data['data']['timestream'])
            if timestream < datetime.datetime.now().timestamp():
                self.send_response(400)
                self.end_headers()
                self.wfile.write(b'Invalid date')
                return
        except ValueError:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b'Invalid date format')
            return

        # Publish to SQS queue
        sqs = boto3.client('sqs')
        sqs.send_message(QueueUrl=sqs_queue_url, MessageBody=json.dumps(data['data']))

        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'Message published to SQS queue')

if __name__ == '__main__':
    server_address = ('', 5000)
    httpd = http.server.HTTPServer(server_address, RequestHandler)
    httpd.serve_forever()