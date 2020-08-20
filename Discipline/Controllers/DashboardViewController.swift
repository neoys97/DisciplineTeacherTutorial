//
//  DashboardViewController.swift
//  Discipline
//
//  Created by Neo Yi Siang on 5/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit
import FirebaseAuth

class DashboardViewController: UIViewController, ReloadableViewController {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let emailKey = "EMAIL"
    let passwordKey = "PASSWORD"
    let defaults = UserDefaults.standard
    var profilePicURL: String?
    
    var rootTabBarController: MainTabBarController!
    let imagePicker = UIImagePickerController()
    let refreshControl = UIRefreshControl()
    var imagePickerTap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootTabBarController = tabBarController as? MainTabBarController

        profilePicImageView.tintColor = Colors.LightCyan
        profilePicImageView.backgroundColor = Colors.BdazzledBlue
        profilePicImageView.layer.cornerRadius = 150
        profilePicImageView.image = UIImage.init(systemName: "person")
        profilePicImageView.contentMode = .scaleAspectFill
        profilePicImageView.layer.masksToBounds = true
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.updateData))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        usernameTF.inputAccessoryView = toolBar
        
        imagePickerTap = UITapGestureRecognizer(target: self, action: #selector(self.showImagePicker))
        profilePicImageView.isUserInteractionEnabled = true
        profilePicImageView.addGestureRecognizer(imagePickerTap)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        scrollView.addSubview(refreshControl)
        
        reloadView()
    }

    override func viewWillAppear(_ animated: Bool) {
        reloadView()
        self.addKeyboardObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardObserver()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        rootTabBarController.refresh()
    }
    
    @objc func showImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = ["public.image"]
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func updateData() {
        view.endEditing(true)
        let updateQuery = [
            "name": usernameTF.text ?? Auth.auth().currentUser!.email!,
        ]
        FirebaseUtil.updateUser(uniqueID: Auth.auth().currentUser!.uid, query: updateQuery as [String : Any]) {[unowned self] (error) in
            if let error = error {
                print (error)
                DispatchQueue.main.async {
                    self.present(Utilities.alertMessage(title: "Error", message: "Failed to update user on Firestore"), animated: true)
                }
            }
            self.rootTabBarController.refresh()
        }
    }
    
    func reloadView() {
        refreshControl.endRefreshing()
        if let teacher = rootTabBarController.teacher {
            if let url = teacher.profilePicURL {
                if let currentURL = profilePicURL {
                    if currentURL != url {
                        profilePicImageView.downloaded(from: url)
                        profilePicURL = url
                    }
                }
                else {
                    profilePicImageView.downloaded(from: url)
                    profilePicURL = url
                }
            }
            else {
                profilePicImageView.image = UIImage(systemName: "person")
            }
            usernameTF.text = teacher.name
        }
    }
    
    @IBAction func logOutBtnPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            defaults.removeObject(forKey: emailKey)
            defaults.removeObject(forKey: passwordKey)
            rootTabBarController.clearData()
            let targetVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginMenu")
            UIApplication.shared.windows.first?.rootViewController = targetVC!
        }
        catch {
            print("Sign out error")
        }
    }
}

extension DashboardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            FirebaseUtil.uploadImage(image: image, mode: .profilePic, uniqueID: Auth.auth().currentUser!.uid) {[unowned self] (url, err) in
                if let err = err {
                    print (err)
                    DispatchQueue.main.async {
                        self.present(Utilities.alertMessage(title: "Error", message: "Failed to upload image to Firestore"), animated: true)
                    }
                }
                else if let url = url {
                    let updateQuery = ["profilePicURL": url]
                    FirebaseUtil.updateUser(uniqueID: Auth.auth().currentUser!.uid, query: updateQuery as [String : Any]) { (error) in
                        if let error = error {
                            print (error)
                            DispatchQueue.main.async {
                                self.present(Utilities.alertMessage(title: "Error", message: "Failed to update user on Firestore"), animated: true)
                            }
                        }
                        else {
                            self.rootTabBarController.teacher!.profilePicURL = url
                            self.profilePicURL = url
                            self.profilePicImageView.image = image
                        }
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
