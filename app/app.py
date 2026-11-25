"""A small web API to run in a container."""
import datetime
import os
import socket

from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def index():
    return jsonify(
        message="Hello from ECS Fargate",
        container=socket.gethostname(),
        version=os.environ.get("APP_VERSION", "dev"),
        time=datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
    )


@app.get("/health")
def health():
    # the load balancer calls this to decide whether the container gets traffic
    return jsonify(status="ok")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
