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

def test_edit_get(new_mock_flask_app):
    """
    GIVEN a Flask application configured for testing
    WHEN the '/docs/<doc_id>/edit' page is requested (GET)
    THEN check that there is a 200 response and the edit form is shown
    """

    response = new_mock_flask_app.get("/docs/test/edit")
    assert response.status_code == 200
    assert b"Welcome to doc Storage" in response.data
    assert b"Edit Document" in response.data
    assert b"Save" in response.data

def test_edit_post(new_mock_flask_app):
    """
    GIVEN a Flask application configured for testing
    WHEN the '/docs/<doc_id>/edit' page is requested (POST) and data is provided
    THEN check that there is a 200 response and the edit form is shown
    """
    #first create something to edit
    data_add = {
        "title" :"add then edit",
        "author":"add then edit author",
        "authorid":"addtheneditauthor_id",
        "publishedDate": "2022-01-01",
        "description": "add then edit me"
    }

    response = new_mock_flask_app.post("/docs/add", follow_redirects=True, data=data_add )    
    assert response.status_code == 200
    assert f"{data_add['author']}".encode() in response.data
    assert f"{data_add['authorid']}".encode() in response.data
    assert f"{data_add['publishedDate']}".encode() in response.data
    assert f"{data_add['description']}".encode() in response.data
    doc_id = flask.request.view_args["doc_id"]

    #now edit
    data_edited = {
        "title" :"test edited",
        "author":"test edited author",
        "authorid":"testeditauthor_id",
        "publishedDate": "2022-01-02",
        "description": "test edited description"
    }

    response = new_mock_flask_app.post(f"/docs/{doc_id}/edit", follow_redirects=True, data=data_edited )
    assert response.status_code == 200
    assert f"{data_edited['author']}".encode() in response.data
    assert f"{data_edited['title']}".encode() in response.data
    assert f"{data_edited['authorid']}".encode() in response.data
    assert f"{data_edited['publishedDate']}".encode() in response.data
    assert f"{data_edited['description']}".encode() in response.data
    # ensure previous entry dooesnt exist as should be edited 
    assert f"{data_add['author']}".encode() not in response.data
    assert f"{data_add['authorid']}".encode() not in response.data
    assert f"{data_add['publishedDate']}".encode() not in response.data
    assert f"{data_add['description']}".encode() not in response.data

def test_delete_get(new_mock_flask_app):
    """
    GIVEN a Flask application configured for testing
    WHEN the '/docs/<doc_id>/delete' page is requested (GET)
    THEN check that there is a 200 response and the edit form is shown
    """

    #first create something to delete
    data = {
        "title" :"test delete",
        "author":"test delete author",
        "authorid":"testdeleteauthor_id",
        "publishedDate": "2022-01-03",
        "description": "test delete me"
    }

    response = new_mock_flask_app.post("/docs/add", follow_redirects=True, data=data )
    assert response.status_code == 200
    assert f"{data['author']}".encode() in response.data
    assert f"{data['authorid']}".encode() in response.data
    assert f"{data['publishedDate']}".encode() in response.data
    assert f"{data['description']}".encode() in response.data
    doc_id = flask.request.view_args["doc_id"]

    # now delete it
    response = new_mock_flask_app.get(f"/docs/{doc_id}/delete", follow_redirects=True )
    assert response.status_code == 200
    assert f"{data['author']}".encode() not in response.data
    assert f"{data['authorid']}".encode() not in response.data
    assert f"{data['title']}".encode() not in response.data