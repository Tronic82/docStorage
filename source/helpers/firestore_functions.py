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