from helpers import firestore_functions

# the document_to_dict function has 2 outcomes, one if the docmunent provcided is empty and one with a valid document
def test_document_to_dict_empty(new_mock_firestore):
    """ 
    GIVEN a firestore database instance
    WHEN no firestore document is returned
    THEN check the function returns NONE
    """
    # get an empty document
    doc = new_mock_firestore.collection(u'fs_unit_test').document("test_doc")
    assert firestore_functions.document_to_dict(doc.get()) == None

def test_document_to_dict(new_mock_firestore):
    """ 
    GIVEN a firestore database instance
    WHEN a firestore document is returned
    THEN check the function returns a dictionary
    """
    #create a mock doc
    doc = new_mock_firestore.collection(u'fs_unit_test').document("test_doc")
    doc.set({
        'first': 'Ada',
        'last': 'Lovelace'
    })
    assert isinstance(firestore_functions.document_to_dict(doc.get()),dict)