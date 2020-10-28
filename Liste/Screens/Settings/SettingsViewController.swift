//
//  SettingsViewController.swift
//  Liste
//
//  Created by Arash on 17/10/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    // MARK: Actions
    @IBAction func dismissButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func signOutButton(_ sender: Any) {
        self.displayAlert(title: NSLocalizedString("signOutTitle", comment: "Are you sure you'd like to sign out?"), message: NSLocalizedString("signOutMessage", comment: "Your session will be reset and you'll need to sign in again.")) { (alert) in
            alert.addAction(UIAlertAction(title: NSLocalizedString("signOut", comment: "Sign out."), style: .destructive, handler: { (_) in
                do {
                    try Auth.auth().signOut()
                } catch let error {
                    print("Error (while signing out): \(error.localizedDescription)")
                    self.displayAlert(title: NSLocalizedString("errorOccurred", comment: "An error occurred."), message: error.localizedDescription, override: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel an action."), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
