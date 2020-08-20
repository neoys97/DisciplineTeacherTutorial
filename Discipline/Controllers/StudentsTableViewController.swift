//
//  StudentsTableViewController.swift
//  DisciplineTeacher
//
//  Created by Neo Yi Siang on 17/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit

class StudentsTableViewController: UITableViewController, ReloadableViewController {
    
    var rootTabBarController: MainTabBarController!

    override func viewDidLoad() {
        super.viewDidLoad()
        rootTabBarController = tabBarController as? MainTabBarController
        print (rootTabBarController.students)
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
        if (segue.identifier == "showStudentSegue") {
            let dest = segue.destination as! StudentViewController
            let studentID = rootTabBarController.studentsKeys![tableView.indexPathForSelectedRow!.row]
            dest.student = rootTabBarController.students![studentID]!
            dest.classGroup = rootTabBarController.classGroup
            dest.books = rootTabBarController.currentClassBooks 
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let students = rootTabBarController.students else { return 0 }
        return students.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (100.0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentsCellIdentifier", for: indexPath) as! StudentsTableViewCell
        guard let students = rootTabBarController.students else { return cell }
        let student = students[rootTabBarController.studentsKeys![indexPath.row]]!
        cell.studentName.text = student.name
        
        return cell
    }
}
