//
//  BookListTableViewController.swift
//  Discipline
//
//  Created by Neo Yi Siang on 7/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit
import FirebaseAuth

class BookListTableViewController: UITableViewController, ReloadableViewController {

    var rootTabBarController: MainTabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootTabBarController = tabBarController as? MainTabBarController
        
        self.refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        reloadView()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        rootTabBarController.refresh()
    }
    
    func reloadView() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "viewBookDetailSegue") {
            let dest = segue.destination as! BookDetailViewController
            let bookID = rootTabBarController.currentClassBooksKeys![tableView.indexPathForSelectedRow!.row]
            dest.book = rootTabBarController.currentClassBooks![bookID]!
            dest.classGroups = rootTabBarController.classGroup
            dest.classGroupsKeys = rootTabBarController.classGroupKeys
            dest.newBook = false
        }
        else if (segue.identifier == "addBookDetailSegue") {
            let dest = segue.destination as! BookDetailViewController
            dest.classGroups = rootTabBarController.classGroup
            dest.classGroupsKeys = rootTabBarController.classGroupKeys
            dest.newBook = true
            dest.rootTabBarController = rootTabBarController
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let bookList = rootTabBarController.currentClassBooks else { return 0 }
        return bookList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (100.0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookListCellIdentifier", for: indexPath) as! BookListTableViewCell
        guard let bookList = rootTabBarController.currentClassBooks else { return cell }
        let book = bookList[rootTabBarController.currentClassBooksKeys![indexPath.row]]!
        cell.bookNameLabel.text = book.name
        cell.bookIconView.tintColor = Colors.BdazzledBlue
        cell.bookIconView.backgroundColor = UIColor.clear
        cell.bookIconView.image = UIImage.init(systemName: "book")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let boughtAction = UIContextualAction(style: .normal, title: "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            tableView.isUserInteractionEnabled = false
            let bookID = self.rootTabBarController.currentClassBooksKeys![indexPath.row]
            FirebaseUtil.removeBook(uniqueID: bookID) { (error) in
                if let error = error {
                    print (error)
                    DispatchQueue.main.async {
                        self.present(Utilities.alertMessage(title: "Error", message: "Failed to update user on Firestore"), animated: true)
                    }
                }
                else {
                    self.rootTabBarController.currentClassBooks?.removeValue(forKey: bookID)
                    let index = self.rootTabBarController.currentClassBooksKeys?.firstIndex(of: bookID)
                    self.rootTabBarController.currentClassBooksKeys?.remove(at: index!)
                    self.rootTabBarController.currentClassBooksKeys?.sort()
                    tableView.reloadData()
                }
                tableView.isUserInteractionEnabled = true
            }
            success(true)
        })
        boughtAction.image = UIImage(systemName: "trash")
        boughtAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [boughtAction])
    }
}
