//
//  DataManager.swift
//
//  Created by Andrii Ilnitskyi on 3/26/19.
//  Copyright © 2019 Andrii Ilnitskyi. All rights reserved.
//

import Foundation
import Firebase

protocol FSPresentable {
    init(documentId: String, data: [String: Any])
    func dictionary() -> [String: Any]
    var documentId: String { get set }
}

class DataManager<T: FSPresentable> {
    private let path: String
    private let db: Firestore
    
    init(path: String) {
        self.path = path
        db = Firestore.firestore()
    }
    
    func addDataListener(_ handler:@escaping ([T])->()) {
        db.collection(path).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            var list = [T]()
            for doc in documents {
                list.append(T.init(documentId: doc.documentID, data: doc.data()))
            }
            
            handler(list)
        }
    }
    
    func getObjects(_ handler:@escaping ([T])->()) {
        db.collection(path).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            var list = [T]()
            for doc in documents {
                list.append(T.init(documentId: doc.documentID, data: doc.data()))
            }
            
            handler(list)
        }
    }
    
    func addObject(_ object: T) {
        db.collection(path).addDocument(data: object.dictionary()) { (err) in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func updateObject(_ objectToUpdate: T, withContentFromObject objectFromUpdate: T) {
        db.collection(path).document(objectToUpdate.documentId).setData(objectFromUpdate.dictionary(), merge: true)
    }
    
    func removeObject(_ object: T) {
        db.collection(path).document(object.documentId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}
