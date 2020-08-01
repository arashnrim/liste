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
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Functions
    func validateInputs() -> Bool {
        guard let taskName = taskNameField.text else {
            print("Warning: Something happened when retrieving the value for taskName.")
            return false
        }
        
        return !(taskName.isEmpty || taskName == "")
    }
    
    func prepareTask() -> Task {
        guard let taskName = taskNameField.text else {
            print("Warning: Something happened when retrieving the value for taskName.")
            return Task(taskName: "", dueDate: Date(), completionStatus: false)
        }
        let dueDate = taskDuePicker.date
        
        let task = Task(taskName: taskName, dueDate: dueDate, completionStatus: false)
        return task
    }
    
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
