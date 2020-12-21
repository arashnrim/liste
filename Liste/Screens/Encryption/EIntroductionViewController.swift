//
//  EIntroductionViewController.swift
//  Liste
//
//  Created by Arash on 20/12/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Firebase

class EIntroductionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Actions
    @IBAction func noButton(_ sender: Any) {
        let database = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Warning: No authenticated user is found; attempting to recover by redirection.")
            self.showReauthenticationAlert()
            return
        }
        database.document("users/\(userID)").updateData(["encrypted": false]) { (error) in
            if let error = error {
                print("Error (fetching from Firebase database): \(error.localizedDescription)")
                self.displayAlert(title: "Uh oh.", message: error.localizedDescription, override: nil)
            } else {
                database.document("users/\(userID)").getDocument { (snapshot, error) in
                    if let error = error {
                        print("Error (fetching from Firebase database): \(error.localizedDescription)")
                        self.displayAlert(title: "Uh oh.", message: error.localizedDescription, override: nil)
                    } else {
                        if let snapshot = snapshot {
                            let data = snapshot.data()
                            if let data = data {
                                if let configured = data["configured"] as? Bool {
                                    if !(configured) {
                                        self.performSegue(withIdentifier: "onboard", sender: nil)
                                    } else {
                                        self.performSegue(withIdentifier: "tasks", sender: nil)
                                    }
                                }
                            } else {
                                print("Warning: The snapshot data appears to be empty.")
                            }
                        }
                    }
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "onboard" {
            let destination = segue.destination
            destination.hero.modalAnimationType = .slide(direction: .left)
        } else if segue.identifier == "tasks" {
            let destination = segue.destination
            destination.hero.modalAnimationType = .uncover(direction: .down)
        }
    }

}
