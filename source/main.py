import os
from helpers import storage_functions
from flask import current_app, Flask
import logging
import google.cloud.logging

def upload_doc_file(doc_file):
    """
    Upload the user-uploaded file to Google Cloud Storage and retrieve its
    publicly-accessible URL.

    Args:
        doc_file (filestream): filestream of the object that needs to be uploaded
        
    Returns:
        string: public URL of uploaded file
    """
    if not doc_file:
        return None

    public_url = storage_functions.upload_file(
        doc_file.read(),
        doc_file.filename,
        doc_file.content_type
    )

    current_app.logger.info(
        f'Uploaded file {doc_file.filename} as {public_url}.')

    return public_url

# create flask app
app = Flask(__name__)
app.config.update(
    #set max content to 1MB
    MAX_CONTENT_LENGTH=8 * 1024 * 1024,
    ALLOWED_EXTENSIONS=set(['png', 'jpg', 'jpeg', 'gif', 'pdf', 'txt'])
)

# debug only in any environment that isnt production
if os.getenv("environment") == "production":
    app.debug = False
    app.testing = False
else:
    app.debug = True
    app.testing = True

# Configure logging
logging.basicConfig(level=logging.INFO)
logging_client = google.cloud.logging.Client()
# Attaches a Google logging handler to the root logger
logging_client.setup_logging(logging.INFO)