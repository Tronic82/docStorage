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

# the read function has 2 outcomes, where the document doesnt exist and where it does
def test_read_no_doc(new_mock_firestore):
    """ 
    GIVEN a firestore database instance
    WHEN a firestore document id doesnt exist
    THEN check the function returns NONE
    """

    # try to read a document that doesnt exist
    assert firestore_functions.read(client=new_mock_firestore, pdfdoc_id="test_doc_no_exist", collection_name="fs_unit_test") == None

def test_read_doc(new_mock_firestore):
    """ 
    GIVEN a firestore database instance
    WHEN a firestore document id exists
    THEN check the function returns a dictionary
    """
    #create a mock doc
    doc = new_mock_firestore.collection(u'fs_unit_test').document("test_doc")
    doc.set({
        'first': 'Ada_read',
        'last': 'Lovelace_read'
    })
    assert isinstance(firestore_functions.read(client=new_mock_firestore, pdfdoc_id="test_doc", collection_name="fs_unit_test"),dict)

def test_create(new_mock_firestore):
    """ 
    GIVEN a firestore database instance
    WHEN data is provided and no ID is provided
    THEN check the function creates a firestore document
    """
    data = {
        'first': 'Ada_create',
        'last': 'Lovelace_create'
    }

    created_doc = firestore_functions.create(client=new_mock_firestore, data=data, collection_name="fs_unit_test")
    assert isinstance(created_doc,dict)
    # the idea here is that if the doc is created, firestore creates an ID for it. as we dont have access 
    # to this ID, we set the ID here after the first assertion to ensure it is created first. When the test runs, 
    # it will fail if anyone of the values dont match up
    # and since IDs are relatively unique, there is low chance of a previously created instance having the same ID and the same values
    data['id'] = created_doc['id']
    assert created_doc == data

def test_update(new_mock_firestore):
    """ 
    GIVEN a firestore database instance
    WHEN data is provided and ID is provided
    THEN check the function updates a firestore document
    """
    #create an existing firebase document
    #create a mock doc
    doc = new_mock_firestore.collection(u'fs_unit_test').document("test_doc_update")
    doc.set({
        'first': 'Ada_update',
        'last': 'Lovelace_update'
    })

    created_doc = new_mock_firestore.collection(u'fs_unit_test').document("test_doc_update").get().to_dict()
    assert isinstance(created_doc,dict)
    #ensure the data is actually created
    assert created_doc == {
        'first': 'Ada_update',
        'last': 'Lovelace_update'
        }
    data = {
        'nickname': 'happy feet'
    }
    assert firestore_functions.update(client=new_mock_firestore, data=data, pdfdoc_id="test_doc_update", collection_name="fs_unit_test") == {'id': 'test_doc_update','nickname': 'happy feet'}

def test_delete(new_mock_firestore):
    """ 
    GIVEN a firestore database instance
    WHEN ID is provided
    THEN check the function deletes the firestore document
    """
    #create an existing firebase document
    #create a mock doc
    doc = new_mock_firestore.collection(u'fs_unit_test').document("test_doc_delete")
    doc.set({
        'first': 'Ada_delete',
        'last': 'Lovelace_delete'
    })
    #ensure the doc has been created
    assert new_mock_firestore.collection(u'fs_unit_test').document("test_doc_delete").get().exists
    # now delete the document
    firestore_functions.delete(client=new_mock_firestore, pdfdoc_id="test_doc_delete", collection_name="fs_unit_test")
    assert not new_mock_firestore.collection(u'fs_unit_test').document("test_doc_delete").get().exists