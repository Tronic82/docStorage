import os
import io
from helpers import storage_functions, firestore_functions
from flask import current_app, Flask, request, render_template, render_template, url_for, redirect, send_file
import logging
import google.cloud.logging
from google.cloud import firestore
from google.cloud import storage
from webapp import web_app

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
        storage_client,
        doc_file.read(),
        doc_file.filename,
        doc_file.content_type
    )

    current_app.logger.info(
        f'Uploaded file {doc_file.filename} as {public_url}.')

    return public_url

# create flask app
app = web_app.create_app()

# debug only in any environment that isnt production
if os.getenv("ENVIRONMENT") == "production":
    app.debug = False
    app.testing = False
    app.config['firestore_col'] = "doc_prod"
else:
    app.debug = True
    app.testing = True
    app.config['firestore_col'] = "doc_dev"

# Configure logging
logging.basicConfig(level=logging.INFO)
logging_client = google.cloud.logging.Client()
# Attaches a Google logging handler to the root logger
logging_client.setup_logging()
#configure firestore
firestore_client = firestore.Client()
# configure storage
storage_client = storage.Client()

@app.route('/')
def list():
    # determine if program needs to list from a specific file
    start_after = request.args.get('start_after', None)
    docs, last_title = firestore_functions.next_page(client=firestore_client, start_after=start_after,collection_name = current_app.config['firestore_col'])

    return render_template('list.html', docs=docs, last_title=last_title)

@app.route('/docs/<doc_id>')
def view(doc_id):
    doc = firestore_functions.read(client=firestore_client, pdfdoc_id=doc_id,collection_name = current_app.config['firestore_col'])
    return render_template('view.html', doc=doc)

@app.route('/docs/add', methods=['GET', 'POST'])
def add():
    if request.method == 'POST':
        data = request.form.to_dict(flat=True)

        # If an image was uploaded, update the data to point to the new image.
        image_hash = upload_doc_file(request.files.get('image'))
        data_hash = upload_doc_file(request.files.get('file'))
        if request.files.get('file'):
            data_file= request.files.get('file').filename
            data_content_type = request.files.get('file').content_type

        if request.files.get('image'):
            image_file = request.files.get('image').filename
            image_content_type = request.files.get('image').content_type
        

        if image_hash:
            data['content_type'] = image_content_type
            data['file_name'] = image_file
            data[f'{image_file}'] = image_hash
        
        if data_hash:
            data['content_type'] = data_content_type
            data['file_name'] = data_file
            data[f'{data_file}'] = data_hash

        

        doc = firestore_functions.create(client=firestore_client, data=data,collection_name = current_app.config['firestore_col'])

        return redirect(url_for('.view', doc_id=doc['id']))

    return render_template('form.html', action='Add', doc={})

@app.route('/docs/<doc_id>/edit', methods=['GET', 'POST'])
def edit(doc_id):
    doc = firestore_functions.read(client=firestore_client, pdfdoc_id=doc_id, collection_name = current_app.config['firestore_col'])

    if request.method == 'POST':
        data = request.form.to_dict(flat=True)

        # If an image was uploaded, update the data to point to the new image.
        image_url = upload_doc_file(request.files.get('image'))
        data_url = upload_doc_file(request.files.get('file'))

        if image_url:
            data['imageUrl'] = image_url
        
        if data_url:
            data['fileUrl'] = data_url

        doc = firestore_functions.update(client=firestore_client, data=data, pdfdoc_id=doc_id, collection_name = current_app.config['firestore_col'])

        return redirect(url_for('.view', doc_id=doc['id']))

    return render_template('form.html', action='Edit', doc=doc)

@app.route('/docs/<doc_id>/delete')
def delete(doc_id):
    firestore_functions.delete(client=firestore_client, pdfdoc_id=doc_id,collection_name = current_app.config['firestore_col'])
    return redirect(url_for('.list'))

@app.route('/docs/<doc_id>/download')
def download(doc_id):
    #first we need to get the meatadata for docuemnt that needs to be downloaded 
    doc = firestore_functions.read(client=firestore_client, pdfdoc_id=doc_id,collection_name = current_app.config['firestore_col'])
    # get the filename to be downlaoded
    file_name = doc["file_name"]
    # then, using the human readable filename get the object name in GCS
    gcs_object_name = doc[file_name]
    #now download the file
    data = io.BytesIO(storage_functions.download_file(storage_client,gcs_object_name))
    #data_mimeTypes = mime.from_file(data)
    return send_file(data, mimetype=doc["content_type"], as_attachment=True, download_name=file_name)

# This is only used when running locally. When running live, gunicorn runs
# the application.
if __name__ == '__main__':
    app.run(host='127.0.0.1', port=80, debug=True)