from app import app


def test_index_and_health():
    client = app.test_client()
    body = client.get("/").get_json()
    assert body["message"] == "Hello from ECS Fargate" and "container" in body
    assert client.get("/health").get_json() == {"status": "ok"}
