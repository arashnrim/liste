//
//  FMSuccessViewController.swift
//  Liste
//
//  Created by Arash on 10/10/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import SwiftConfettiView
import Firebase

class FMSuccessViewController: UIViewController {

    // MARK: Properties
    var tasks: [Task] = []
    var task: Task?
    var row: Int?

    // MARK: Outlets
    @IBOutlet weak var confettiView: SwiftConfettiView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.confettiView.startConfetti()

        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(stopConfetti), userInfo: nil, repeats: false)

        UserDefaults.standard.removeObject(forKey: "focusModeMaxTime")
        UserDefaults.standard.removeObject(forKey: "focusModeStarted")
    }

    // MARK: Functions
    @objc func stopConfetti() {
        self.confettiView.stopConfetti()
    }

    /**
     * Updates the user's tasks on the database.
     *
     * This function contacts the Firestore database and sets the data of the user's `tasks` key. This key should be inclusive of the user's previous tasks; failing to do so may result in the user's previous tasks being overwritten.
     *
     * This function also assumes that the tasks are converted to the Firestore JSON form of `[String: [String: Any]]`. Use the `convertTaskToJSON` function to assist the conversion.
     *
     * - Parameters:
     *      - tasks: The user's tasks, in the Firestore JSON form of `[String: [String: Any]]`.
     *      - completion: A closure for code to run following a successful update.
     */
    func updateDatabase(tasks: [String: [String: Any]], completion: @escaping (() -> Void)) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Warning: No authenticated user is found; future functions may fail.")
            return
        }
        let database = Firestore.firestore()

        database.document("users/\(userID)").updateData(["tasks": tasks]) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.displayAlert(title: "An error occurred.", message: error.localizedDescription, override: nil)
            } else {
                completion()
            }
        }
    }

    // MARK: Actions
    @IBAction func finishButton(_ sender: ListeButton) {
        self.displayAlert(title: "Mark task as complete?", message: "Would you like to mark your task as complete?") { (alert) in
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                // Changes the completion status of the task.
                self.task!.completionStatus = true
                self.tasks[self.row!] = self.task!
                let tasks = self.convertTaskToJSON(tasks: self.tasks)
                self.updateDatabase(tasks: tasks) {
                    print("Silent database change successful.")
                    self.performSegue(withIdentifier: "home", sender: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (_) in
                self.performSegue(withIdentifier: "home", sender: nil)
            }))
            self.show(alert, sender: nil)
        }
    }
}
