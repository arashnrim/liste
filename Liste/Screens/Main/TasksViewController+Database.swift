//
//  TasksViewController+Database.swift
//  Liste
//
//  Created by Arash on 12/09/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Firebase

extension TasksViewController {

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
            } else {
                print(UserDefaults.standard.string(forKey: "masterPassword"))
                let encrypted = data["encrypted"] as? Bool
                if encrypted == nil {
                    self.performSegue(withIdentifier: "encrypt", sender: nil)
                }
            }
        }
    }

    /**
     * Reads the user's `tasks` and performs actions on them.
     *
     * - Parameters:
     *      - data: A `[String:Any]` parameter, preferably the data retrieved from the Firestore database.
     */
    func readTasks(data: [String: Any], completion: (([Task]) -> Void)?) {
        if let tasks = data["tasks"] as? [String: [String: Any]] {
            verifyEncryption(data: data)
            let convertedTasks = self.convertJSONToTask(tasks: tasks)
            self.tasks += convertedTasks
            self.tasksTableView.reloadData()
            refreshControl.endRefreshing()

            if let completion = completion {
                completion(self.tasks)
            }
        }
    }

    func verifyEncryption(data: [String: Any]) {
        if let encrypted = data["encrypted"] as? Bool {
            if encrypted && UserDefaults.standard.string(forKey: "masterPassword") == nil {
                self.performSegue(withIdentifier: "decrypt", sender: nil)
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
        tasks = []
        retrieveDatabase { (data) in
            self.readTasks(data: data, completion: nil)
        }
    }

}
