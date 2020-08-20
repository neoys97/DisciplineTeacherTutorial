//
//  BookDetailViewController.swift
//  Discipline
//
//  Created by Neo Yi Siang on 7/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class BookDetailViewController: UIViewController {

    @IBOutlet weak var bookStatusLabel: UILabel!
    @IBOutlet weak var bookNameTF: UITextField!
    @IBOutlet weak var classgroupTF: UITextField!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var addBookButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    var imagePickerTap: UITapGestureRecognizer!
    var rootTabBarController: MainTabBarController!
    
    var book: Book?
    var currentBookImageURL: String?
    var classGroups: [String: ClassGroup]!
    var classGroupsKeys: [String]!
    var newBook = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.BurntSienna
        bookImageView.tintColor = Colors.LightCyan
        bookImageView.backgroundColor = UIColor.clear
        bookImageView.layer.cornerRadius = 20
        bookImageView.image = UIImage(systemName: "book.circle")
        bookNameTF.backgroundColor = UIColor.clear
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        imagePickerTap = UITapGestureRecognizer(target: self, action: #selector(self.showImagePicker))
        bookImageView.addGestureRecognizer(imagePickerTap)
        
        let classGroupPicker = UIPickerView()
        classGroupPicker.delegate = self
        classgroupTF.inputView = classGroupPicker
        classgroupTF.tintColor = UIColor.clear
        
        if let book = book {
            bookImageView.isUserInteractionEnabled = false
            bookNameTF.text = book.name
            bookNameTF.isUserInteractionEnabled = false
            bookNameTF.borderStyle = .none
            classgroupTF.isUserInteractionEnabled = false
            classgroupTF.text = classGroups[book.classGroupID]!.name
            bookStatusLabel.text = "Book Detail"
            if let url = book.imageURL {
                bookImageView.downloaded(from: url, contentMode: .scaleAspectFit)
            }
            addBookButton.isHidden = true
        }
        else {
            bookImageView.isUserInteractionEnabled = true
            bookNameTF.text = ""
            bookNameTF.isUserInteractionEnabled = true
            classgroupTF.isUserInteractionEnabled = true
            classgroupTF.text = "Select Class"
            addBookButton.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addKeyboardObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardObserver()
    }
    
    @IBAction func addBookBtnPressed(_ sender: Any) {
        if let bookName = bookNameTF.text, bookName != "", let classGroup = classgroupTF.text, let classGroupID = searchForClassGroupID(name: classGroup) {
            if newBook {
                let bookAdding = Book(name: bookName, classGroupID: classGroupID)
                if let url = currentBookImageURL {
                    bookAdding.imageURL = url
                }
                view.isUserInteractionEnabled = false
                FirebaseUtil.newBook(book: bookAdding) {[unowned self] (error) in
                    if let error = error {
                        print (error)
                        DispatchQueue.main.async {
                            present(Utilities.alertMessage(title: "Error", message: "Failed to update user on Firestore"), animated: true)
                        }
                    }
                    else {
                        rootTabBarController.refresh()
                    }
                    view.isUserInteractionEnabled = true
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func showImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = ["public.image"]
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func searchForClassGroupID(name: String) -> String? {
        for (key, value) in classGroups {
            if (value.name == name) {
                return key
            }
        }
        return nil
    }
}

extension BookDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        view.isUserInteractionEnabled = false
        if let image = info[.originalImage] as? UIImage {
            FirebaseUtil.uploadImage(image: image, mode: .bookImage, uniqueID: UUID().uuidString) {[unowned self] (url, err) in
                if let err = err {
                    print (err)
                    DispatchQueue.main.async {
                        present(Utilities.alertMessage(title: "Error", message: "Failed to upload image to Firestore"), animated: true)
                    }
                }
                else if let url = url {
                    currentBookImageURL = url
                    bookImageView.image = image
                }
                view.isUserInteractionEnabled = true
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

extension BookDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return classGroups.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return classGroups[classGroupsKeys[row]]?.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        classgroupTF.text = classGroups[classGroupsKeys[row]]?.name
    }
}
