from google.cloud import firestore

def document_to_dict(doc):
    """This function creates a dictionary object containing details of a document

    Args:
        doc (firestore document): The firestore document object

    Returns:
        Dict: a dictionary containing a firestore document and metadata
    """
    if not doc.exists:
        return None
    doc_dict = doc.to_dict()
    doc_dict['id'] = doc.id
    return doc_dict

def read(pdfdoc_id):
    """This function reads firestore for the specified document

    Args:
        pdfdoc_id (Any): the ID of the document to read

    Returns:
        Dict: a dictionary of the document and its metadata
    """
    
    db_client = firestore.Client()
    pdfdoc_ref = db_client.collection(u'pdfdoc').document(pdfdoc_id)
    snapshot = pdfdoc_ref.get()
   
    return document_to_dict(snapshot)

def next_page(limit=10, start_after=None):
    """This function returns documents from firestore

    Args:
        limit (int, optional): The number of documents to look for. Defaults to 10.
        start_after (String, optional): denotes the starting document to begin listing. Defaults to None.

    Returns:
        tuple: returns a firestore document and the title of the last document found
    """
    db = firestore.Client()

    query = db.collection(u'pdfdoc').limit(limit).order_by(u'title')

    if start_after:
        # Construct a new query starting at this document.
        query = query.start_after({u'title': start_after})

    docs = query.stream()
    docs = list(map(document_to_dict, docs))

    last_title = None
    if limit == len(docs):
        # Get the last document from the results and set as the last title.
        last_title = docs[-1][u'title']
    return docs, last_title

def update(data, pdfdoc_id=None):
    """This function creates or updates an existing document in firestore. When pdfdoc_id is None, it will create the document

    Args:
        data (Dict): The update data
        pdfdoc_id (String, optional): The ID of the document that needs to be updated. Defaults to None.

    Returns:
        Dict: the document with the updated information
    """
    db = firestore.Client()
    pdfdoc_ref = db.collection(u'pdfdoc').document(pdfdoc_id)
    pdfdoc_ref.set(data)
    return document_to_dict(pdfdoc_ref.get())

create = update

def delete(id):
    """This function deletes an existing document

    Args:
        id (String): The ID of the document that needs to be deleted
    """
    db = firestore.Client()
    pdfdoc_ref = db.collection(u'pdfdoc').document(id)
    pdfdoc_ref.delete()