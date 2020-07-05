//
//  TasksViewController.swift
//  Liste
//
//  Created by Arash Nur Iman on 01/10/19.
//  Copyright © 2019 Apprendre. All rights reserved.
//

import UIKit
import Firebase
import Hero

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var listNameTextField: UITextField!
    @IBOutlet weak var tasksTableView: UITableView!
    
    // MARK: Properties
    var reference: DatabaseReference!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        
        retrieveDatabase { (data) in
            print(data)
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        #warning("Placeholder value; change this when data is available.")
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath) as! TaskTableViewCell
        
        return cell
    }
    
    // MARK: Functions
    func retrieveDatabase(_ completion: @escaping (NSDictionary) -> Void) {
        reference = Database.database().reference()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: The current user resulted to be nil; prompting the user to authenticate again.")
            showReauthenticationAlert()
            return
        }
        
        reference.child("users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            let data = snapshot.value as? NSDictionary
            if let data = data {
                completion(data)
            } else {
                print("Error: The data doesn't exist.")
            
            }
        }
    }
    
    func showReauthenticationAlert() {
        self.displayAlert(title: "Uh oh.", message: "An authentication error occured. You'll be redirected for authentication again.") { (alert) in
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.performSegue(withIdentifier: "auth", sender: nil)
            }))
        }
    }
    
}

