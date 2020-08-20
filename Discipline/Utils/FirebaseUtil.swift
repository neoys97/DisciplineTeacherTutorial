//
//  FirebaseUtil.swift
//  Discipline
//
//  Created by Neo Yi Siang on 5/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class FirebaseUtil {
    static let db = Firestore.firestore()
    static let studentRef = db.collection("students")
    static let teacherRef = db.collection("teachers")
    static let classRef = db.collection("classGroups")
    static let bookRef = db.collection("books")
    static let toDoImageRef = Storage.storage().reference().child("ToDo")
    static let profilePicRef = Storage.storage().reference().child("ProfilePic")
    static let bookImageRef = Storage.storage().reference().child("BookImage")
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func newUser(uniqueID: String, name: String, completionHandler: ((_ teacher: Teacher?, _ err: Error?)->Void)?) throws {
        let newTeacher = Teacher(name: name)
        try teacherRef.document(uniqueID).setData(from: newTeacher) { err in
            if let completionHandler = completionHandler {
                completionHandler(newTeacher, err)
            }
        }
    }
    
    static func newBook(book: Book, completionHandler: ((_ err: Error?)->Void)?) {
        guard let completionHandler = completionHandler else {
            print("Missing completion handler")
            return
        }
        let _ = try? bookRef.addDocument(from: book) { err in
            completionHandler(err)
        }
    }
    
    static func removeBook(uniqueID: String, completionHandler: ((_ err: Error?)->Void)?) {
        guard let completionHandler = completionHandler else {
            print("Missing completion handler")
            return
        }
        bookRef.document(uniqueID).delete() { err in
            completionHandler(err)
        }
    }
    
    static func getUser(uniqueID: String, completionHandler:((_ teacher: Teacher?, _ err: Error?)->Void)?) {
        guard let completionHandler = completionHandler else {
            print("Missing completion handler")
            return
        }
        teacherRef.document(uniqueID).getDocument { (document, error) in
            let result = Result {
                try document?.data(as: Teacher.self)
            }
            switch result {
                case .success(let teacher):
                    completionHandler(teacher, nil)
                case .failure(let error):
                    completionHandler(nil, error)
            }
        }
    }
    
    static func getAllClassGroups(completionHandler:((_ classGroups: [String: ClassGroup]?, _ err: Error?)->Void)?) {
        guard let completionHandler = completionHandler else {
            print("Missing completion handler")
            return
        }
        classRef.getDocuments() { (snapshot, err) in
            if let err = err {
                completionHandler(nil, err)
            }
            else {
                var retrievedData = [String: ClassGroup]()
                for document in snapshot!.documents {
                    let temp = try? document.data(as: ClassGroup.self)
                    retrievedData[document.documentID] = temp
                }
                completionHandler(retrievedData, nil)
            }
        }
    }
    
    static func getAllBooks(completionHandler: ((_ books: [String: Book]?, _ error: Error?)->Void)?) {
        guard let completionHandler = completionHandler else {
            print("Missing completion handler")
            return
        }
        bookRef.getDocuments { (snapshot, error) in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                var bookDictionary = [String: Book]()
                for document in snapshot!.documents {
                    let temp = try? document.data(as: Book.self)
                    bookDictionary[document.documentID] = temp
                }
                completionHandler(bookDictionary, nil)
            }
        }
    }
    
    static func getAllStudents(completionHandler: ((_ students: [String: Student]?, _ error: Error?)->Void)?) {
        guard let completionHandler = completionHandler else {
            print("Missing completion handler")
            return
        }
        studentRef.getDocuments { (snapshot, error) in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                var studentDictionary = [String: Student]()
                for document in snapshot!.documents {
                    let temp = try? document.data(as: Student.self)
                    studentDictionary[document.documentID] = temp
                }
                completionHandler(studentDictionary, nil)
            }
        }
    }
    
    static func updateUser(uniqueID: String, query: [String: Any], completionHandler:((_ err: Error?)->Void)?) {
        guard let completionHandler = completionHandler else {
            print("Missing completion handler")
            return
        }
        teacherRef.document(uniqueID).updateData(query) { error in
            completionHandler(error)
        }
    }
    
    static func uploadImage(image: UIImage, mode: uploadImageMode, uniqueID: String, completionHandler:((_ url: String?, _ err: Error?) -> Void)?) {
        guard let completionHandler = completionHandler else {
            print("Missing completion handler")
            return
        }
        let imageName = "\(uniqueID).jpg"
        
        var storageRef: StorageReference
        switch (mode) {
            case .profilePic:
                storageRef = profilePicRef
            case .toDoImage:
                storageRef = toDoImageRef
            case .bookImage:
                storageRef = bookImageRef
        }
        storageRef = storageRef.child(imageName)
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: uploadMetadata) { (downloadMetadata, error) in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                storageRef.downloadURL { (url, err) in
                    if let error = err {
                        completionHandler(nil, error)
                    }
                    else {
                        completionHandler(url!.absoluteString, nil)
                    }
                }
            }
        }
    }
}

enum uploadImageMode {
    case profilePic, toDoImage, bookImage
}
