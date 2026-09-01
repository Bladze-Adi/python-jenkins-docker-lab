import pytest
from app.app import app


@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_home_route(client):
    response = client.get('/')
    assert response.status_code == 200
    json_data = response.get_json()
    assert json_data['status'] == 'success'
    assert 'version' in json_data


def test_health_route(client):
    response = client.get('/health')
    assert response.status_code == 200
    json_data = response.get_json()
    assert json_data['status'] == 'healthy'
