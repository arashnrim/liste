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
}
