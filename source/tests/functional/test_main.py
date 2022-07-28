import flask

def test_list(new_mock_flask_app):
    """
    GIVEN a Flask application configured for testing
    WHEN the '/' page is requested (GET)
    THEN check that there is a valid response
    """

    response = new_mock_flask_app.get("/")
    assert response.status_code == 200
    assert b"Welcome to doc Storage" in response.data
    assert b"Documents Available" in response.data
    assert b"List Documents" in response.data

def test_view(new_mock_flask_app):
    """
    GIVEN a Flask application configured for testing
    WHEN the '/docs' page is requested (GET) without a parameter
    THEN check that there is a 404 response
    """

    response = new_mock_flask_app.get("/docs/")
    assert response.status_code == 404
    response = new_mock_flask_app.get("/docs")
    assert response.status_code == 404

def test_add_get(new_mock_flask_app):
    """
    GIVEN a Flask application configured for testing
    WHEN the '/docs/add' page is requested (GET)
    THEN check that there is a 200 response and the form is shown
    """

    response = new_mock_flask_app.get("/docs/add")
    assert response.status_code == 200
    assert b"Welcome to doc Storage" in response.data
    assert b"Add Document" in response.data
    assert b"Save" in response.data