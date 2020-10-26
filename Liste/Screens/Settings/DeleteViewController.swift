//
//  DeleteViewController.swift
//  Liste
//
//  Created by Arash on 24/10/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Firebase

class DeleteViewController: UIViewController {

    // MARK: Properties
    var userID: String = ""

    // MARK: Actions
    @IBAction func deleteDataButton(_ sender: Any) {
        self.displayAlert(title: NSLocalizedString("deleteDataTitle", comment: "Are you sure you'd like to delete your data?"), message: NSLocalizedString("deleteDataMessage", comment: "All your tasks will be deleted from your account, and your list will be deleted.")) { (alert) in
            alert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: "Delete."), style: .destructive, handler: { (_) in
                print("Data deletion process initiated.")
                // Clears the Firestore database.
                let overrideData: [String: Any] = ["tasks": [String: Any](), "listName": ""]
                Firestore.firestore().document("users/\(self.userID)").updateData(overrideData) { (error) in
                    if let error = error {
                        print("Error occurred (while deleting user data): \(error.localizedDescription)")
                    } else {
                        print("Data deletion process concluded successfully.")
                        self.performSegue(withIdentifier: "postDeletion", sender: nil)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel an action."), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
