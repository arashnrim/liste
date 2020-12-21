//
//  EChangeViewController.swift
//  Liste
//
//  Created by Arash on 20/12/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit

class EChangeViewController: UIViewController, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet weak var currentMasterPasswordTextField: UITextField!
    @IBOutlet weak var newMasterPasswordTextField: UITextField!
    @IBOutlet weak var continueButton: ListeButton!

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentMasterPasswordTextField.delegate = self
        self.newMasterPasswordTextField.delegate = self

        self.dismissKeyboardOnTap {
            guard let currentPassword = self.currentMasterPasswordTextField.text else { return }
            guard let newPassword = self.newMasterPasswordTextField.text else { return }
            if (currentPassword != newPassword) && (!currentPassword.isEmpty && !newPassword.isEmpty) {
                self.continueButton.isEnabled = true
                UIView.animate(withDuration: 0.5) {
                    self.continueButton.alpha = 1.0
                }
            } else {
                self.continueButton.isEnabled = false
                UIView.animate(withDuration: 0.5) {
                    self.continueButton.alpha = 0.5
                }
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "encrypt" {
            guard let newPassword = newMasterPasswordTextField.text else { return }
            let destination = segue.destination as! EEncryptingViewController
            destination.newPassword = newPassword
        }
    }

    // MARK: Text Field Protocols
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let currentPassword = currentMasterPasswordTextField.text else { return }
        guard let newPassword = newMasterPasswordTextField.text else { return }
        if (currentPassword != newPassword) && (!currentPassword.isEmpty && !newPassword.isEmpty) {
            self.continueButton.isEnabled = true
            UIView.animate(withDuration: 0.5) {
                self.continueButton.alpha = 1.0
            }
        } else {
            self.continueButton.isEnabled = false
            UIView.animate(withDuration: 0.5) {
                self.continueButton.alpha = 0.5
            }
        }

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case currentMasterPasswordTextField:
            currentMasterPasswordTextField.resignFirstResponder()
            newMasterPasswordTextField.becomeFirstResponder()
        case newMasterPasswordTextField:
            view.endEditing(true)
        default:
            break
        }
        return false
    }

    // MARK: Actions
    @IBAction func continueButton(_ sender: Any) {
        guard let currentpassword = currentMasterPasswordTextField.text else { return }
        guard let newpassword = newMasterPasswordTextField.text else { return }
        guard let masterPassword = UserDefaults.standard.string(forKey: "masterPassword") else { return }

        if masterPassword == currentpassword {
            UserDefaults.standard.set(newpassword, forKey: "masterPassword")
            UserDefaults.standard.set(currentpassword, forKey: "outdatedMasterPassword")

            self.performSegue(withIdentifier: "encrypt", sender: nil)
        } else {
            self.displayAlert(title: "That's not right.", message: "The curernt master password is incorrect. Please try again!", override: nil)
        }
    }

}
