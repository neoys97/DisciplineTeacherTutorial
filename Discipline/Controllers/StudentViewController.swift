//
//  StudentViewController.swift
//  DisciplineTeacher
//
//  Created by Neo Yi Siang on 17/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit

class StudentViewController: UIViewController {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var classgroupTF: UITextField!
    
    @IBOutlet weak var toDoListSectionView: UIView!
    @IBOutlet weak var toDoListCompleteTF: UILabel!
    @IBOutlet weak var booksSectionView: UIView!
    @IBOutlet weak var booksCompleteTF: UILabel!
    
    var student: Student?
    var classGroup: [String: ClassGroup]?
    var books: [String: Book]?
    var profilePicURL: String?
    
    var rootTabBarController: MainTabBarController!

    override func viewDidLoad() {
        super.viewDidLoad()
        rootTabBarController = tabBarController as? MainTabBarController

        usernameTF.isUserInteractionEnabled = false
        classgroupTF.isUserInteractionEnabled = false
        profilePicImageView.isUserInteractionEnabled = false
        
        profilePicImageView.tintColor = Colors.LightCyan
        profilePicImageView.backgroundColor = Colors.BdazzledBlue
        profilePicImageView.layer.cornerRadius = 75
        profilePicImageView.image = UIImage.init(systemName: "person")
        profilePicImageView.contentMode = .scaleAspectFill
        profilePicImageView.layer.masksToBounds = true
        
        toDoListSectionView.layer.cornerRadius = 20

        booksSectionView.layer.cornerRadius = 20
        
        reloadView()
    }

    override func viewWillAppear(_ animated: Bool) {
        reloadView()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        rootTabBarController.refresh()
    }

    func reloadView() {
        if let student = self.student {
            if let url = student.profilePicURL {
                profilePicImageView.downloaded(from: url, contentMode: .scaleAspectFill)
                profilePicURL = url
            }
            else {
                profilePicImageView.image = UIImage(systemName: "person")
            }
            usernameTF.text = student.name
            if let classID = student.classGroupID {
                if let classGroups = classGroup {
                    classgroupTF.text = classGroups[classID]?.name
                }
                else {
                    classgroupTF.text = "No class selected"
                }
            }
            else {
                classgroupTF.text = "No class selected"
            }
            updateStatusView(student: student)
        }
    }
    
    func updateStatusView(student: Student) {
        toDoListCompleteTF.text = "Incomplete"
        toDoListSectionView.backgroundColor = Colors.BurntSienna
        if let desc = student.toDoDesc, desc != "" {
            if let _ = student.toDoImageURL {
                toDoListCompleteTF.text = "Complete"
                toDoListSectionView.backgroundColor = Colors.BdazzledBlue
            }
        }
        
        booksCompleteTF.text = "Incomplete"
        booksSectionView.backgroundColor = Colors.BurntSienna
        var neededBooks = [String]()
        for (key, value) in books! {
            if value.classGroupID == student.classGroupID {
                neededBooks.append(key)
            }
        }
        
        if neededBooks.sorted() == student.books.sorted() {
            booksCompleteTF.text = "Complete"
            booksSectionView.backgroundColor = Colors.BdazzledBlue
        }
        
    }
}
