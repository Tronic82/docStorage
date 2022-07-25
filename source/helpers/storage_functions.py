import os
import datetime
import hashlib
from werkzeug.exceptions import BadRequest
from werkzeug.utils import secure_filename
from flask import current_app
from google.cloud import storage

def _check_extension(filename, allowed_extensions):
    """This Function checks whether the filename conforms to the allowed extensions

    Args:
        filename (String): The name of the file to test
        allowed_extensions (List): A comma seperated list of extensions

    Raises:
        BadRequest: Raises an exception if the extension is not in the allowed list
    """
    file, ext = os.path.splitext(filename)
    if (ext.replace('.', '').lower() not in allowed_extensions):
        raise BadRequest(
            f'{filename} has an invalid name or extension')

def _safe_filename(filename):
    """
    Generates a unique filename that is unlikely to collide with existing
    objects in Google Cloud Storage.

    ``filename.ext`` is transformed into ``filenameYYYYMMDDHHMMSS.ext`` 
    filename is then ran through sha256 to generate a unique filename for GCS Bucket 

    Args:
        filename (String): The name of the file

    Returns:
        String: sha256 hexdigest of the new computed file name
    """
    filename = secure_filename(filename)
    date = datetime.datetime.utcnow().strftime("%Y%m%d%H%M%S")
    basename, extension = filename.rsplit('.', 1)
    tempname = f"{basename}{date}{extension}".encode('utf-8')
    hashname = hashlib.sha256(tempname).hexdigest()
    return hashname

def upload_file(file_stream, filename, content_type):
    """
    Uploads a file to a given Cloud Storage bucket and returns the public url
    to the new object.

    Args:
        file_stream (String): The filestream being read 
        filename (String): name of the file to be uploaded
        content_type (): the content type the file

    Returns:
        string: url to the uploaded file
    """
    # as only PDFs are allowed, we need to check the user isnt trying to upload any other file
    _check_extension(filename, current_app.config['ALLOWED_EXTENSIONS'])
    filename = _safe_filename(filename)

    bucketname = os.getenv('GOOGLE_STORAGE_BUCKET') or f"{os.getenv( 'GOOGLE_CLOUD_PROJECT')}-file-bucket"

    gcs_client = storage.Client()
    gcs_bucket = gcs_client.bucket(bucketname)
    blob = gcs_bucket.blob(filename)

    blob.upload_from_string(
        file_stream,
        content_type=content_type)

    # provide a url to the storage object
    url = blob.public_url

    # check to see if string needs decoding before being returned
    if isinstance(url, bytes):
        url = url.decode('utf-8')

    return url