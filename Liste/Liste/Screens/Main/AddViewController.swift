//
//  AddViewController.swift
//  Liste
//
//  Created by Arash on 31/07/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Firebase

class AddViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskDescriptionView: UITextView!
    @IBOutlet weak var taskDuePicker: UIDatePicker!
    
    // MARK: Properties
    var tasks: [Task] = []
    
    // MARK: Functions
    /**
     * Verifies if the user's inputs are valid.
     *
     * This function checks only the fundementally important part of a task: its name. This function checks if `taskName` is empty (either an empty string or simply empty). If so, then the check returns a `false`. Otherwise, a check returns a `true`.
     *
     * - Returns: A boolean value of the outcome of the check.
     */
    func validateInputs() -> Bool {
        guard let taskName = taskNameField.text else {
            print("Warning: Something happened when retrieving the value for taskName.")
            return false
        }
        
        return !(taskName.isEmpty || taskName == "")
    }
    
    /**
     * Prepares and compiles all the information given into a `Task`.
     *
     * This function reads all the data provided and filled by the user, and afterwards compiles them in the `Task` type.
     *
     * - Returns: A `Task` of the compiled data.
     */
    func prepareTask() -> Task {
        guard let taskName = taskNameField.text else {
            print("Warning: Something happened when retrieving the value for taskName.")
            return Task(taskName: "", dueDate: Date(), completionStatus: false)
        }
        let dueDate = taskDuePicker.date
        
        let task = Task(taskName: taskName, dueDate: dueDate, completionStatus: false)
        return task
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
    func updateDatabase(tasks: [String: [String: Any]], _ completion: @escaping (() -> Void)) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Warning: No authenticatd user is found; future functions may fail.")
            return
        }
        let database = Firestore.firestore()
        
        database.document("users/\(userID)").setData(["tasks": tasks]) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.displayAlert(title: "An error occurred.", message: error.localizedDescription, override: nil)
            }
            else {
                completion()
            }
        }
    }
    
    // MARK: Actions
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        let isValid = validateInputs()
        
        if isValid {
            tasks.append(prepareTask())
            let jsonTasks = self.convertTaskToJSON(tasks: tasks)
            self.updateDatabase(tasks: jsonTasks) {
                self.performSegue(withIdentifier: "dismiss", sender: nil)
            }
        } else {
            self.displayAlert(title: "Whoops!", message: "Some fields are invalid. Please take a look at your fields and try again.", override: nil)
        }
    }
    
}
