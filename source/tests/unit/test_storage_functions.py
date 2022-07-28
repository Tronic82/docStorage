import io
from google.cloud import storage
from unittest import mock
from werkzeug.datastructures import FileStorage
from werkzeug.exceptions import BadRequest
from helpers import storage_functions
import pytest

def test_upload_file(new_mock_flask_app):
    """ 
    GIVEN a storage instance
    WHEN a file is to be uploaded
    THEN check the function calls the upload function with the given file
    """
    # create a test file stream
    file_to_upload = (io.BytesIO(b"this is a test"), 'test.pdf')
    storage_client = mock.create_autospec(storage.Client)
    mock_bucket = mock.create_autospec(storage.Client.bucket)
    mock_blob = mock.create_autospec(storage.Blob)
    mock_publicUrl = mock.create_autospec(storage.Blob.public_url)
    mock_bucket.return_value = mock_blob
    storage_client.bucket("test-bucket").return_value = mock_bucket
    storage_client.bucket("test-bucket").blob("test-filename").return_value = mock_blob
    storage_client.bucket("test-bucket").blob("test-filename").return_value.public_url.return_value = mock_publicUrl

    # assign filestream
    test_filestream = FileStorage(*file_to_upload)
    # run test
    storage_functions.upload_file(storage_client,test_filestream.read(),test_filestream.filename,bucket=storage_client.bucket("test-bucket").return_value, content_type=test_filestream.content_type)
    storage_client.bucket("test-bucket").blob("test-filename").upload_from_string.assert_called_once_with(b"this is a test", content_type=test_filestream.content_type)

def test_check_extension(new_mock_flask_app):
    """ 
    GIVEN a file
    WHEN a file is to be uploaded
    THEN check a bad request exception is raised when the extension is invalid
    """
    # ALLOWED_EXTENSIONS=set(['png', 'jpg', 'jpeg', 'gif', 'pdf', 'txt']) found in fixtures config
    correct_filename= "test.pdf"
    incorrect_filename = "test.exe"

    #assert a bad request is raised for incorrect file name
    with pytest.raises(BadRequest):
        storage_functions._check_extension(incorrect_filename,new_mock_flask_app.application.config.get('ALLOWED_EXTENSIONS'))

    #assert no exception if using correct file name
    try:
        storage_functions._check_extension(correct_filename,new_mock_flask_app.application.config.get('ALLOWED_EXTENSIONS'))
    except BadRequest:
        assert False, f"{correct_filename} has an invalid name or extension"