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

def test_add_post(new_mock_flask_app):
    """
    GIVEN a Flask application configured for testing
    WHEN the '/docs/add' page is requested (POST) and data is provided
    THEN check that there is a 200 response and the form is shown
    """
    data = {
        "title" :"test add",
        "author":"test author",
        "authorid":"testauthor_id",
        "publishedDate": "2022-01-01",
        "description": "test description"
    }

    response = new_mock_flask_app.post("/docs/add", follow_redirects=True, data=data )
    
    assert response.status_code == 200
    assert f"{data['author']}".encode() in response.data
    assert f"{data['title']}".encode() in response.data
    assert f"{data['authorid']}".encode() in response.data
    assert f"{data['publishedDate']}".encode() in response.data
    assert f"{data['description']}".encode() in response.data