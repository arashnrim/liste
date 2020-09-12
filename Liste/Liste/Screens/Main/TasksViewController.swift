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

/**
 * All code regarding UI elements of the Tasks View Controller resides here.
 *
 * To view the declaration of code functions interacting with the database, view `TasksViewController+Database.swift`.
 *
 * - See also: TasksViewController+Database.swift
 */
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
            self.loadingView.isHidden = false
            self.emptyView.isHidden = false

            UIView.animate(withDuration: 0.5) {
                self.loadingView.alpha = 1.0
                self.emptyView.alpha = 1.0
            }

            self.readUserStatus(data: data)
            self.readTasks(data: data) { (tasks) in
                if !(tasks.isEmpty) {
                    if self.loadingView != nil && self.emptyView != nil {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.emptyView.alpha = 0.0
                        }) { (_) in
                            self.emptyView.isHidden = true
                            UIView.animate(withDuration: 0.5, animations: {
                                self.loadingView.alpha = 0.0
                            }) { (_) in
                                self.loadingView.isHidden = true
                            }
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
            guard let indexPath = tasksTableView.indexPathForSelectedRow else {
                print("Warning: Something went wrong while retrieving the table view cell's index path information.")
                return
            }
            destination.heroModalAnimationType = .selectBy(presenting: .slide(direction: .left), dismissing: .slide(direction: .right))
            destination.task = tasks[indexPath.row]
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

    // MARK: Actions
    @IBAction func unwindToTasks(_ unwindSegue: UIStoryboardSegue) {
        tasks = []
        retrieveDatabase { (data) in
            self.emptyView.isHidden = false

            UIView.animate(withDuration: 0.5) {
                self.emptyView.alpha = 1.0
            }

            self.readUserStatus(data: data)
            self.readTasks(data: data) { (tasks) in
                if !(tasks.isEmpty) {
                    if self.emptyView != nil {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.emptyView.alpha = 0.0
                        }) { (_) in
                            self.emptyView.isHidden = true
                        }
                    }
                } else {
                    self.emptyView.isHidden = false

                    if self.emptyView != nil {
                        UIView.animate(withDuration: 0.5) {
                            self.emptyView.alpha = 1.0
                        }
                    }
                }
            }
            self.readListName(data: data)
        }
        self.tasksTableView.reloadData()
    }

}
