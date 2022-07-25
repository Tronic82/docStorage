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