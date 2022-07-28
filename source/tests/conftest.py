import pytest
import mockfirestore
import main

@pytest.fixture(scope='module')
def new_mock_firestore():
    mock_db = mockfirestore.MockFirestore()
    return mock_db

@pytest.fixture(scope='module')
def new_mock_flask_app():
    test_app = main.app
    with test_app.test_client() as testing_client:
        # Establish an application context
        with test_app.app_context():
            yield testing_client