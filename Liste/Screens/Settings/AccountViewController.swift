//
//  AccountViewController.swift
//  Liste
//
//  Created by Arash on 24/10/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var accountIDLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tasksLabel: UILabel!

    // MARK: Properties
    var userID: String = ""

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Pulls all the required data and populates the labels.
        if let currentUser = Auth.auth().currentUser {
            self.accountIDLabel.text = currentUser.uid
            self.emailLabel.text = currentUser.email
        }

        var tasks: [Task] = []
        let firestore = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Warning: No authenticated user is found; future functions may fail.")
            return
        }
        self.userID = userID
        firestore.document("users/\(userID)").getDocument { (snapshot, error) in
            if let error = error {
                print("Error (while retrieving user data): \(error.localizedDescription)")
            } else {
                if let snapshot = snapshot {
                    let data = snapshot.data()
                    let databaseTasks = data!["tasks"] as! [String: [String: Any]]
                    tasks = self.convertJSONToTask(tasks: databaseTasks)
                    self.tasksLabel.text = String(tasks.count)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "delete" {
            let destination = segue.destination as! DeleteViewController
            destination.userID = self.userID
        }
    }

    // MARK: Actions
    @IBAction func reset(_ sender: Any) {
        let database = Firebase.Firestore.firestore()
        guard let userID = Firebase.Auth.auth().currentUser?.uid else { return }

        database.document("users/\(userID)").getDocument { (snapshot, error) in
            if let error = error {
                self.displayAlert(title: "Something went wrong.", message: error.localizedDescription, override: nil)
            } else {
                if let snapshot = snapshot {
                    if let data = snapshot.data() {
                        if let encrypted = data["encrypted"] as? Bool {
                            let alert = UIAlertController(title: "Heads up!", message: "Managing your encryption is a potentially dangerous action. If you do so, you may lose access to your data.", preferredStyle: .actionSheet)
                            if encrypted {
                                alert.addAction(UIAlertAction(title: "Change master password", style: .default, handler: { (_) in
                                    self.performSegue(withIdentifier: "change", sender: nil)
                                }))
                                alert.addAction(UIAlertAction(title: "Reset master password", style: .destructive, handler: { (_) in
                                    let subAlert = UIAlertController(title: "Take note!", message: "This action will render all your existing tasks useless; therefore, they will be deleted. Continue?", preferredStyle: .alert)
                                    subAlert.addAction(UIAlertAction(title: "Continue", style: .destructive, handler: { (_) in
                                        UserDefaults.standard.removeObject(forKey: "encryptionPassword")

                                        database.document("users/\(userID)").updateData(["tasks": [String: Any](), "listName": ""]) { (error) in
                                            if error != nil {
                                                self.displayAlert(title: "Something went wrong.", message: "Your action for managing encryption will be terminated.", override: nil)
                                            } else {
                                                self.performSegue(withIdentifier: "reset", sender: nil)
                                            }
                                        }
                                    }))
                                    subAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                                    self.present(subAlert, animated: true, completion: nil)
                                }))
                            } else {
                                alert.addAction(UIAlertAction(title: "Set up encryption", style: .default, handler: { (_) in
                                    self.performSegue(withIdentifier: "reset", sender: nil)
                                }))
                            }
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}
