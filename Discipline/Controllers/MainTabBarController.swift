//
//  MainTabBarController.swift
//  Discipline
//
//  Created by Neo Yi Siang on 5/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class MainTabBarController: UITabBarController {
    
    var teacher: Teacher?
    var classGroupKeys: [String]?
    var classGroup: [String: ClassGroup]?
    var currentClassBooksKeys: [String]?
    var currentClassBooks: [String: Book]?
    var studentsKeys: [String]?
    var students: [String: Student]?
        
    let authUserInfo = Auth.auth().currentUser
    var loadingIndicatorView: ActivityIndicatorView!
    
    var usersLoading = false
    var classLoading = false
    var booksLoading = false
    var studentsLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicatorView = ActivityIndicatorView(title: "Fetching data...", center: self.view.center)
        view.addSubview(self.loadingIndicatorView.getViewActivityIndicator())
        refresh()
    }
    
    func refresh() {
        clearData()
        retrieveAllClassGroups()
        retrieveUser()
        retrieveAllStudents()
        retrieveAllBooks()
    }
    
    func retrieveUser() {
        usersLoading = true
        view.isUserInteractionEnabled = false
        loadingIndicatorView.startAnimating()
        FirebaseUtil.getUser(uniqueID: authUserInfo!.uid) {[unowned self] teacher, error in
            if let teacher = teacher {
                self.teacher = teacher
            }
            else {
                if let error = error {
                    loadDataErrorAlert(error: error)
                }
                else {
                    DispatchQueue.main.async {
                        self.present(Utilities.alertMessage(title: "Server error", message: "User data is missing in the server, please contact the admin"), animated: true)
                    }
                }
            }
            usersLoading = false
            reloadCurrentViewController()
        }
    }
    
    func retrieveAllClassGroups() {
        classLoading = true
        view.isUserInteractionEnabled = false
        loadingIndicatorView.startAnimating()
        FirebaseUtil.getAllClassGroups { [unowned self] (retrievedData, error) in
            if let error = error {
                loadDataErrorAlert(error: error)
            }
            else if let classes = retrievedData{
                self.classGroup = classes
                self.classGroupKeys = [String](classes.keys).sorted()
            }
            classLoading = false
            reloadCurrentViewController()
        }
    }
    
    func retrieveAllBooks() {
        booksLoading = true
        view.isUserInteractionEnabled = false
        loadingIndicatorView.startAnimating()
        FirebaseUtil.getAllBooks() {[unowned self] (books, error) in
            if let error = error {
                loadDataErrorAlert(error: error)
            }
            else if let books = books {
                self.currentClassBooks = books
                self.currentClassBooksKeys = [String](books.keys).sorted()
            }
            classLoading = false
            reloadCurrentViewController()
        }
    }
    
    func retrieveAllStudents() {
        studentsLoading = true
        view.isUserInteractionEnabled = false
        loadingIndicatorView.startAnimating()
        FirebaseUtil.getAllStudents() {[unowned self] (students, error) in
            if let error = error {
                loadDataErrorAlert(error: error)
            }
            else if let students = students {
                self.students = students
                self.studentsKeys = [String](students.keys).sorted()
            }
            studentsLoading = false
            reloadCurrentViewController()
        }
    }
    
    func reloadCurrentViewController() {
        guard checkLoading() else { return }
        if let currentViewController = selectedViewController as? ReloadableViewController {
            currentViewController.reloadView()
        }
        else if let currentNavController = selectedViewController as? UINavigationController {
            if let currentViewController = currentNavController.topViewController as? ReloadableViewController {
                currentViewController.reloadView()
            }
        }
        view.isUserInteractionEnabled = true
        loadingIndicatorView.stopAnimating()
    }
    
    func checkLoading() -> Bool {
        if usersLoading || classLoading || booksLoading || studentsLoading {
            return true
        }
        return false
    }
    
    func clearData() {
        self.teacher = nil
        self.classGroupKeys = nil
        self.classGroup = nil
        self.currentClassBooksKeys = nil
        self.currentClassBooks = nil
        self.studentsKeys = nil
        self.students = nil
    }
    
    func loadDataErrorAlert(error: Error?) {
        DispatchQueue.main.async {
            self.present(Utilities.alertMessage(title: "Data error", message: "Failed to retrive data"), animated: true)
        }
        print(error)
    }
}

protocol ReloadableViewController {
    func reloadView()
}
