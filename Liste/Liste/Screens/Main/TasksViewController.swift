//
//  TasksViewController.swift
//  Liste
//
//  Created by Arash Nur Iman on 01/10/19.
//  Copyright © 2019 Apprendre. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import Hero

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var listNameTextField: UITextField!
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var loadingView: UIView!

    // MARK: Properties
    var tasks = [Task]()
    var refreshControl = UIRefreshControl()

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        tasksTableView.delegate = self
        tasksTableView.dataSource = self

        listNameTextField.delegate = self

        retrieveDatabase { (data) in
            self.readUserStatus(data: data)
            self.readTasks(data: data)
            self.readListName(data: data)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTable), name: NSNotification.Name(rawValue: "NotificationID"), object: nil)

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.reloadTable), for: .valueChanged)
        tasksTableView.addSubview(refreshControl)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "auth" {
            let destination = segue.destination
            destination.heroModalAnimationType = .zoomOut
        } else if segue.identifier == "add" {
            let destination = segue.destination as! AddViewController
            destination.tasks = tasks
        } else if segue.identifier == "info" {
            let destination = segue.destination as! InfoViewController
            destination.heroModalAnimationType = .selectBy(presenting: .slide(direction: .left), dismissing: .slide(direction: .right))
        }
    }

    // MARK: Table View Protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath) as! TaskTableViewCell

        let task = tasks[indexPath.row]
        cell.titleLabel.text = task.taskName
        cell.dueLabel.text = self.convertDateToString(date: task.dueDate)
        cell.mainView.layer.cornerRadius = 8
        cell.mainView.layer.masksToBounds = true

        let clearView = UIView()
        clearView.backgroundColor = UIColor.clear
        cell.backgroundView = clearView

        let completed = task.completionStatus
        if completed {
            cell.statusButton.setImage(UIImage(named: "checked"), for: .normal)
        } else {
            cell.statusButton.setImage(UIImage(named: "unchecked"), for: .normal)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "info", sender: nil)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            updateTasks()
            self.tasksTableView.reloadData()
        }
    }

    // MARK: Text Field Protocols
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let newName = listNameTextField.text else {
            print("Warning: newName appears to be empty; the execution of future functions may fail.")
            return false
        }

        textField.resignFirstResponder()

        if !(newName.isEmpty || newName == "") {
            self.changeListName {
                print("List name change appears to be OK.")

                UIView.animate(withDuration: 0.5, animations: {
                    self.listNameTextField.alpha = 1.0
                }) { (_) in
                    self.listNameTextField.isEnabled = true
                }
            }
        } else {
            self.displayAlert(title: "Whoops.", message: "The name of your list cannot be empty.") { (alert) in
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    textField.becomeFirstResponder()
                }))
            }
        }

        return false
    }

    // MARK: Functions
    /**
     * Retrieves all user-related data in the Firestore database.
     *
     * - Parameters:
     *      - completion: A closure with a `[String:Any]` parameter (i.e., data fetched from the database).
     */
    func retrieveDatabase(completion: (([String: Any]) -> Void)?) {
        let database = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Warning: No authenticated user is found; attempting to recover by redirection.")
            self.showReauthenticationAlert()
            return
        }
        database.document("users/\(userID)").getDocument { (snapshot, error) in
            if let error = error {
                print("Error (fetching from Firebase database): \(error.localizedDescription)")
                self.displayAlert(title: "Uh oh.", message: error.localizedDescription, override: nil)
            } else {
                if let snapshot = snapshot {
                    let data = snapshot.data()
                    if let data = data {
                        completion?(data)
                    } else {
                        print("Warning: The snapshot data appears to be empty.")
                    }
                }
            }
        }
    }

    func configureUser() {
        performSegue(withIdentifier: "configure", sender: nil)
    }

    /**
     * Reads the user's `configured` status and performs actions based on the value.
     *
     * - Parameters:
     *      - data: A `[String:Any]` parameter, preferably the data retrieved from the Firestore database.
     */
    func readUserStatus(data: [String: Any]) {
        if let configured = data["configured"] as? Bool {
            if !(configured) {
                self.configureUser()
            }
        }
    }

    /**
     * Reads the user's `tasks` and performs actions on them.
     *
     * - Parameters:
     *      - data: A `[String:Any]` parameter, preferably the data retrieved from the Firestore database.
     */
    func readTasks(data: [String: Any]) {
        if let tasks = data["tasks"] as? [String: [String: Any]] {
            let convertedTasks = self.convertJSONToTask(tasks: tasks)
            self.tasks += convertedTasks
            self.tasksTableView.reloadData()
            refreshControl.endRefreshing()

            self.loadingView.isHidden = false
            self.emptyView.isHidden = false

            UIView.animate(withDuration: 0.5) {
                self.loadingView.alpha = 1.0
                self.emptyView.alpha = 1.0
            }

            if !(tasks.isEmpty) {
                if self.loadingView != nil && self.emptyView != nil {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.loadingView.alpha = 0.0
                        self.emptyView.alpha = 0.0
                    }) { (_) in
                        self.loadingView.isHidden = true
                        self.emptyView.isHidden = true
                    }
                }
            } else {
                self.emptyView.isHidden = false

                if self.loadingView != nil && self.emptyView != nil {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.loadingView.alpha = 0.0
                        self.emptyView.alpha = 1.0
                    }) { (_) in
                        self.loadingView.isHidden = true
                    }
                }
            }
        }
    }

    /**
     * Reads the user's list name.
     *
     * - Parameters:
     *      - data: A `[String:Any]` parameter, preferably the data retrieved from the Firestore database.
     */
    func readListName(data: [String: Any]) {
        if let listName = data["listName"] as? String {
            self.listNameTextField.text = listName
        }
    }

    /**
     * Changes the user's list name.
     *
     * - Parameters:
     *      - completion: An optional closure to run after the update.
     */
    func changeListName(completion: (() -> Void)?) {
        guard let newName = listNameTextField.text else {
            print("Warning: newName appears to be empty; the execution of this function may fail.")
            return
        }
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Warning: No authenticated user is found; attempting to recover by redirection.")
            self.showReauthenticationAlert()
            return
        }

        UIView.animate(withDuration: 0.5, animations: {
            self.listNameTextField.alpha = 0.5
        }) { (_) in
            self.listNameTextField.isEnabled = false
        }

        let database = Firestore.firestore()
        database.document("users/\(userID)").updateData(["listName": newName]) { (error) in
            if let error = error {
                print("Error (while updating list name): \(error.localizedDescription)")
                self.displayAlert(title: "Whoops.", message: error.localizedDescription, override: nil)
            } else {
                completion?()
            }
        }
    }

    func updateTasks() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Warning: No authenticated user is found; attempting to recover by redirection.")
            self.showReauthenticationAlert()
            return
        }
        let database = Firestore.firestore()
        let convertedTasks = self.convertTaskToJSON(tasks: self.tasks)

        self.loadingView.isHidden = false
        self.emptyView.isHidden = false

        UIView.animate(withDuration: 0.5) {
            self.loadingView.alpha = 1.0
            self.emptyView.alpha = 1.0
        }

        database.document("users/\(userID)").updateData(["tasks": convertedTasks]) { (error) in
            if let error = error {
                print("Error (while updating list name): \(error.localizedDescription)")
                self.displayAlert(title: "Whoops.", message: error.localizedDescription, override: nil)
            } else {
                print("Task update successfully changed silently.")

                if !(self.tasks.isEmpty) {
                    if self.loadingView != nil && self.emptyView != nil {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.loadingView.alpha = 0.0
                            self.emptyView.alpha = 0.0
                        }) { (_) in
                            self.loadingView.isHidden = true
                            self.emptyView.isHidden = true
                        }
                    }
                } else {
                    self.emptyView.isHidden = false

                    if self.loadingView != nil && self.emptyView != nil {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.loadingView.alpha = 0.0
                            self.emptyView.alpha = 1.0
                        }) { (_) in
                            self.loadingView.isHidden = true
                        }
                    }
                }
            }
        }
    }

    @objc func reloadTable() {
        self.loadingView.isHidden = false
        self.emptyView.isHidden = false

        UIView.animate(withDuration: 0.5) {
            self.loadingView.alpha = 1.0
            self.emptyView.alpha = 1.0
        }

        tasks = []
        retrieveDatabase { (data) in
            self.readTasks(data: data)
        }
    }

    @IBAction func unwindToTasks(_ unwindSegue: UIStoryboardSegue) {
        tasks = []
        retrieveDatabase { (data) in
            self.readUserStatus(data: data)
            self.readTasks(data: data)
            self.readListName(data: data)
        }
        self.tasksTableView.reloadData()
    }

}
