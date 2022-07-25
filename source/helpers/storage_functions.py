import os
from werkzeug.exceptions import BadRequest

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