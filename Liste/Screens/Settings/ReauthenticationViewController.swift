//
//  ReauthenticationViewController.swift
//  Liste
//
//  Created by Arash on 26/10/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Hero
import Firebase

class ReauthenticationViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signOut" {
            let destination = segue.destination
            destination.hero.modalAnimationType = .zoomOut
        }
    }

    // MARK: Actions
    @IBAction func deleteAccountButton(_ sender: Any) {
        print("Initiating account deletion process.")
        guard let user = Auth.auth().currentUser else { return }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        print("Re-authenticating user...")
        user.reauthenticate(with: credential) { (_, error) in
            if let error = error {
                print("Error occurred (while re-authenticating): \(error.localizedDescription)")
                self.displayAlert(title: NSLocalizedString("errorOccurred", comment: "An error occurred."), message: error.localizedDescription, override: nil)
            } else {
                print("User re-authentication appears to be OK. Proceeding...")
                print("Deleting user data...")
                Firestore.firestore().document("users/\(user.uid)").delete { (error) in
                    if let error = error {
                        print("Error occurred (while deleting user data): \(error.localizedDescription)")
                    } else {
                        print("User data deletion appears to be OK. Proceeding...")
                        print("Clearing UserDefaults...")
                        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                        print("Deleting user account...")
                        user.delete { (error) in
                            if let error = error {
                                print("Error occurred (while deleting account): \(error.localizedDescription)")
                            } else {
                                print("Account deletion process concluded successfully.")
                                self.performSegue(withIdentifier: "signOut", sender: nil)
                            }
                        }
                    }
                }
            }
        }
    }

}
