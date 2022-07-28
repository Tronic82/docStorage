from helpers import firestore_functions

def test_document_to_dict_empty(new_mock_firestore):
    """ 
    GIVEN a firestore database instance
    WHEN no firestore document is returned
    THEN check the function returns NONE
    """
    # get an empty document
    doc = new_mock_firestore.collection(u'fs_unit_test').document("test_doc")
    assert firestore_functions.document_to_dict(doc.get()) == None