import os

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

def read(pdfdoc_id, client,collection_name):
    """This function reads firestore for the specified document

    Args:
        pdfdoc_id (Any): the ID of the document to read
        client: the firestore client

    Returns:
        Dict: a dictionary of the document and its metadata
    """
    
    db_client = client
    pdfdoc_ref = db_client.collection(collection_name).document(pdfdoc_id)
    snapshot = pdfdoc_ref.get()
   
    return document_to_dict(snapshot)

def next_page(client,collection_name, limit=10, start_after=None):
    """This function returns documents from firestore

    Args:
        limit (int, optional): The number of documents to look for. Defaults to 10.
        start_after (String, optional): denotes the starting document to begin listing. Defaults to None.
        client: the firestore client

    Returns:
        tuple: returns a firestore document and the title of the last document found
    """
    db = client

    query = db.collection(collection_name).limit(limit).order_by(u'title')

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

def update(client, data,collection_name, pdfdoc_id=None):
    """This function creates or updates an existing document in firestore. When pdfdoc_id is None, it will create the document

    Args:
        data (Dict): The update data
        pdfdoc_id (String, optional): The ID of the document that needs to be updated. Defaults to None.
        client: the firestore client

    Returns:
        Dict: the document with the updated information
    """
    db = client
    pdfdoc_ref = db.collection(collection_name).document(pdfdoc_id)
    pdfdoc_ref.set(data)
    return document_to_dict(pdfdoc_ref.get())

create = update

def delete(client, pdfdoc_id,collection_name):
    """This function deletes an existing document

    Args:
        id (String): The ID of the document that needs to be deleted
        client: the firestore client
    """
    db = client
    pdfdoc_ref = db.collection(collection_name).document(pdfdoc_id)
    pdfdoc_ref.delete()