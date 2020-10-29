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

class ReauthenticationViewController: UIViewController, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var deleteButton: ListeButton!

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self

        // Assumes deleteButton to be disabled when the view loads.
        deleteButton.changeState(state: false, text: "...")

        // Allows editing to end when any part of the screen is tapped outside the keyboard area.
        self.dismissKeyboardOnTap(completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signOut" {
            let destination = segue.destination
            destination.hero.modalAnimationType = .zoomOut
        }
    }

    // MARK: Text Field Protocols
    func textFieldDidEndEditing(_ textField: UITextField) {
        let valid = validate()
        valid ? deleteButton.changeState(state: true, text: NSLocalizedString("deleteAccount", comment: "Delete account.")) : deleteButton.changeState(state: false, text: "...")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            self.view.endEditing(true)
        default:
            break
        }
        return false
    }

    // MARK: Functions
    /**
     * Checks if the user input in the `emailTextField` and `passwordTextField` fields are valid.
     *
     * This function checks if the value in `emailTextField` is not empty and if it contains the "@" symbol. It also checks if the value in `passwordTextField` is not empty and has a character count of more than five; if both of these statements hold true, then the result is successful. Else, the result is failure.
     *
     * - Returns: A boolean value of the outcome of the check.
     */
    func validate() -> Bool {
        guard let email = emailTextField.text else {
            print("Warning: Email String value appears to be empty; assuming the check result to be false.")
            return false
        }
        guard let password = passwordTextField.text else {
            print("Warning: Password String value appears to be empty; assuming the check result to be false.")
            return false
        }
        let emailValid = !(email.isEmpty) && (email.contains("@"))
        let passwordValid = !(password.isEmpty) && (password.count > 5)

        return emailValid && passwordValid
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
