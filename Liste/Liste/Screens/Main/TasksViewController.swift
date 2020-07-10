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
            if let configured = data["configured"] as? Bool {
                if !(configured) {
                    self.configureUser()
                }
            }
            
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
        
        retrieveUserStatus { (configured) in
            if !(configured) {
                // TODO: Perform onboarding segue here
            }
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
    
    func retrieveUserStatus(_ completion: @escaping (Bool) -> Void) {
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
                        guard let configured = data["configured"] as? Bool else {
                            print("Error: configured in \(snapshot.documentID) is not a Bool.")
                            return
                        }
                        completion(configured)
                    }
                }
            }
        }
    }
    
    func configureUser() {
        // TODO: Write function code to trigger onboarding
    }
    
    /**
     * Presents a customized alert that prompts for user reauthentication.
     *
     * This alert will include a `UIAlertAction` that redirects the user back to Auth storyboard.
     */
    func showReauthenticationAlert() {
        self.displayAlert(title: "Uh oh.", message: "An authentication error occured. You'll be redirected for authentication again.") { (alert) in
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.performSegue(withIdentifier: "auth", sender: nil)
            }))
        }
    }
    
}

