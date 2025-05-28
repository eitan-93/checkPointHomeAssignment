import http.client
import json
import time
import boto3
from http.server import BaseHTTPRequestHandler, HTTPServer


# Load token from SSM Parameter Store
ssm = boto3.client('ssm')
token = ssm.get_parameter(Name='token')['Parameter']['Value']

API_HOST = "api.currencyfreaks.com"
currency_api_key = os.environ['CURRENCY_API_KEY']
API_PATH = f"/v2.0/rates/latest?apikey=${currency_api_key}&symbols=ILS,GBP,EUR,USD"

latest_data = {}

def poll_currency_api():
    global latest_data
    while True:
        try:
            conn = http.client.HTTPSConnection(API_HOST)
            conn.request("GET", API_PATH)
            response = conn.getresponse()
            if response.status == 200:
                data = response.read()
                result = json.loads(data)
                latest_data = {
                    "data": {
                        "content": result,
                        "timestream": int(time.time())
                    },
                    "token": token
                }
                print("Polled currency data:", latest_data)
            else:
                print(f"Error fetching data: {response.status} {response.reason}")
            conn.close()
        except Exception as e:
            print("Polling failed:", e)
        time.sleep(120)

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/currency":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(latest_data).encode("utf-8"))
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == "__main__":
    import threading

    polling_thread = threading.Thread(target=poll_currency_api, daemon=True)
    polling_thread.start()

    server = HTTPServer(("0.0.0.0", 5002), SimpleHTTPRequestHandler)
    print("Starting server on port 5002...")
    server.serve_forever()