//
//  InfoViewController.swift
//  Liste
//
//  Created by Arash on 29/08/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    // MARK: Properties
    var task: Task?
    
    // MARK: Outlets
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskDescriptionView: UITextView!
    @IBOutlet weak var taskDueLabel: UILabel!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Reads the data of the task and applies them on the visual components.
        if let task = task {
            let name = task.taskName
            let description = task.description
            let dueDate = self.convertDateToString(date: task.dueDate)
            
            self.taskNameField.text = name
            
            if description != "" {
                self.taskDescriptionView.text = description
            } else {
                self.taskDescriptionView.text = "No description provided."
                self.taskDescriptionView.textColor = .lightGray
            }
            
            self.taskDueLabel.text = dueDate
        }
    }

    // MARK: Actions
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
