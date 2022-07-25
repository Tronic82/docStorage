import os
import datetime
import hashlib
from werkzeug.exceptions import BadRequest
from werkzeug.utils import secure_filename

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