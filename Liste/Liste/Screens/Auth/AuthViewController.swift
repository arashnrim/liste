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
        
        // Sets the delegate of the text fields as AuthViewController.
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Assumes authButton to be disabled when the view loads.
        authButton.changeState(state: false, text: "...")
        
        // Allows editing to end when any part of the screen is tapped outside the keyboard area.
        self.dismissKeyboardOnTap {
            let valid = self.validate()
            valid ? self.checkUserStatus() : self.authButton.changeState(state: false, text: "...")
        }
        
        // Adds management of on-screen content to move when the keyboard is called.
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
    
    // MARK: Actions
    @IBAction func authButton(_ sender: UIButton) {
        guard let state = authButton.currentTitle else {
            print("Warning: authButton's title appears to be nil; auth procedure may fail.")
            return
        }
        
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
                    self.performSegue(withIdentifier: "complete", sender: nil)
                }
            }
        }
    }
    
}
