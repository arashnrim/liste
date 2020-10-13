//
//  AuthViewController.swift
//  Liste
//
//  Created by Arash Nur Iman on 26/06/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Firebase

class AuthViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var authButton: ListeButton!

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self

        // Assumes authButton to be disabled when the view loads.
        authButton.changeState(state: false, text: "...")

        // Allows editing to end when any part of the screen is tapped outside the keyboard area.
        self.dismissKeyboardOnTap {
            let valid = self.validate()
            valid ? self.checkUserStatus() : self.authButton.changeState(state: false, text: "...")
        }

        // Adds an observer to move the content of the screen upwards when the keyboard is presented.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: Delegate Protocols
    func textFieldDidEndEditing(_ textField: UITextField) {
        let valid = validate()
        valid ? checkUserStatus() : authButton.changeState(state: false, text: "...")
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

    /**
     * Checks if the entered user credentials are linked to an existing account or otherwise.
     *
     * This function calls Firebase's `fetchSignInMethods` method and checks if the sign in methods of the user is `nil`; in other words, it checks if there is an existing user account with the entered credentials. If the sign in methods return `nil`, then `authButton`'s title will be amended to "Sign Up"; otherwise, if the sign in methods return a non-optional value, then `authButton`'s title will be amended to "Sign In".
     */
    func checkUserStatus() {
        guard let email = emailTextField.text else {
            print("Warning: Email String value appears to be empty; assuming the check result to be false.")
            return
        }

        Auth.auth().fetchSignInMethods(forEmail: email) { (methods, error) in
            if let error = error {
                self.displayAlert(title: "An error occurred.", message: error.localizedDescription, override: nil)
            } else {
                if let methods = methods {
                    if !(methods.isEmpty) {
                        self.authButton.changeState(state: true, text: "Sign In")
                    } else {
                        self.authButton.changeState(state: true, text: "Sign Up")
                    }
                } else {
                    self.authButton.changeState(state: true, text: "Sign Up")
                }
            }
        }
    }

    /**
     * Signs the user into the app.
     *
     * This function calls Firebase's `signIn` method to sign the user into the app. Once authentication is successful, the function's `completion` parameter picks up a potential `Error` and allows for greater flexibility following the execution of authentication.
     *
     * - Parameters:
     *      - completion: A closure to run after authentication. An `Error?` is the only parameter for this closure; it is recommended to verify if the error is `nil` before proceeding.
     */
    func signIn(completion: @escaping ((Error?) -> Void)) {
        guard let email = emailTextField.text else {
            print("Warning: Email String value appears to be empty; sign in procedure may fail.")
            return
        }
        guard let password = passwordTextField.text else {
            print("Warning: Password String value appears to be empty; sign in procedure may fail.")
            return
        }

        print("Auth: Attempting to sign user in...")
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            completion(error)
        }
    }

    /**
     * Creates a user account and signs the user into the app.
     *
     * This function calls Firebase's `createUser` method which handles user account creation and user authentication. Once authentication is successful, the function's `completion` parameter picks up a potential `Error` and allows for greater flexibility following the execution of authentication.
     *
     * - Parameters:
     *      - completion: A closure to run after authentication. An `Error?` is the only parameter for this closure; it is recommended to verify if the error is `nil` before proceeding.
     */
    func signUp(completion: @escaping ((Error?) -> Void)) {
        guard let email = emailTextField.text else {
            print("Warning: Email String value appears to be empty; sign up procedure may fail.")
            return
        }
        guard let password = passwordTextField.text else {
            print("Warning: Password String value appears to be empty; sign up procedure may fail.")
            return
        }

        print("Auth: Attempting to create user account...")
        Auth.auth().createUser(withEmail: email, password: password) { (_, error) in
            completion(error)
        }
    }

    func addUserDatabase(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Warning: No authenticated user is found; attempt to recover later on.")
            return
        }

        let database = Firestore.firestore()
        let data = [
            "configured": false,
            "tasks": [],
            "listName": ""
            ] as [String: Any]
        database.document("users/\(userID)").setData(data)
        completion()
    }

    // MARK: Actions
    @IBAction func authButton(_ sender: UIButton) {
        guard let state = authButton.currentTitle else {
            print("Warning: authButton's title appears to be nil; auth procedure may fail.")
            return
        }

        // Checks the 'state' of authButton (from the text, whether it's "Sign In" or "Sign Up") and performs the respective actions.
        // When the 'state' is "Sign In", Firebase's sign in function is invoked.
        // Else, when the 'state' is "Sign Up", Firebase's create user function is invoked.
        if state == "Sign In" {
            self.authButton.changeState(state: false, text: "Signing In...")
            signIn { (error) in
                if let error = error {
                    print("Auth: \(error.localizedDescription)")
                    self.displayAlert(title: "An error occurred.", message: error.localizedDescription, override: nil)
                    self.authButton.changeState(state: true, text: "Sign In")
                } else {
                    print("Auth: Auth appears to be OK.")
                    self.performSegue(withIdentifier: "complete", sender: nil)
                }
            }
        } else {
            self.authButton.changeState(state: false, text: "Signing Up...")
            signUp { (error) in
                if let error = error {
                    print("Auth: \(error.localizedDescription)")
                    self.displayAlert(title: "An error occurred.", message: error.localizedDescription, override: nil)
                    self.authButton.changeState(state: true, text: "Sign Up")
                } else {
                    print("Auth: Auth appears to be OK.")
                    print("Database: Setting up user database...")

                    self.addUserDatabase {
                        print("Database: Database creation appears to be OK.")
                        self.performSegue(withIdentifier: "complete", sender: nil)
                    }
                }
            }
        }
    }

}
