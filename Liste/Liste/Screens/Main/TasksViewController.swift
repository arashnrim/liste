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

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var listNameTextField: UITextField!
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var loadingView: UIView!
    
    // MARK: Properties
    var tasks = [Task]()
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        
        retrieveDatabase { (data) in
            self.readUserStatus(data: data)
            self.readTasks(data: data)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "auth" {
            let destination = segue.destination
            destination.heroModalAnimationType = .zoomOut
        }
    }
    
    // MARK: Table View Protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath) as! TaskTableViewCell
        
        let task = tasks[indexPath.row]
        cell.titleLabel.text = task.taskName
        cell.dueLabel.text = task.dueDate
        
        let completed = task.completionStatus
        if completed {
            cell.statusButton.setImage(UIImage(named: "checked"), for: .normal)
        } else {
            cell.statusButton.setImage(UIImage(named: "unchecked"), for: .normal)
        }
        
        return cell
    }
    
    // MARK: Functions
    /**
     * Retrieves all user-related data in the Firestore database.
     *
     * - Parameters:
     *      - completion: A closure with a `[String:Any]` parameter (i.e., data fetched from the database).
     */
    func retrieveDatabase(_ completion: (([String:Any]) -> Void)?) {
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
    func readUserStatus(data: [String:Any]) {
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
     *      - data: A `[String:Any` parameter, preferably the data retrieved from the Firestore database.
     */
    func readTasks(data: [String:Any]) {
        if let tasks = data["tasks"] as? [String:[String:Any]] {
            let convertedTasks = self.convertJSONToTask(tasks: tasks)
            self.tasks += convertedTasks
            self.tasksTableView.reloadData()
            
            UIView.animate(withDuration: 0.5, animations: {
                self.loadingView.alpha = 0.0
                self.emptyView.alpha = 0.0
            }) { (_) in
                self.loadingView.removeFromSuperview()
                self.emptyView.removeFromSuperview()
            }
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.loadingView.alpha = 0.0
            }) { (_) in
                self.loadingView.removeFromSuperview()
            }
        }
    }
    
}

