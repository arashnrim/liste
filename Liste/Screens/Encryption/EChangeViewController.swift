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
    @IBOutlet weak var currentEncryptionPasswordTextField: UITextField!
    @IBOutlet weak var newEncryptionPasswordTextField: UITextField!
    @IBOutlet weak var continueButton: ListeButton!

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentEncryptionPasswordTextField.delegate = self
        self.newEncryptionPasswordTextField.delegate = self

        self.dismissKeyboardOnTap {
            guard let currentPassword = self.currentEncryptionPasswordTextField.text else { return }
            guard let newPassword = self.newEncryptionPasswordTextField.text else { return }
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
            guard let newPassword = newEncryptionPasswordTextField.text else { return }
            let destination = segue.destination as! EEncryptingViewController
            destination.newPassword = newPassword
        }
    }

    // MARK: Text Field Protocols
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let currentPassword = currentEncryptionPasswordTextField.text else { return }
        guard let newPassword = newEncryptionPasswordTextField.text else { return }
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
        case currentEncryptionPasswordTextField:
            currentEncryptionPasswordTextField.resignFirstResponder()
            newEncryptionPasswordTextField.becomeFirstResponder()
        case newEncryptionPasswordTextField:
            view.endEditing(true)
        default:
            break
        }
        return false
    }

    // MARK: Actions
    @IBAction func continueButton(_ sender: Any) {
        guard let currentpassword = currentEncryptionPasswordTextField.text else { return }
        guard let newpassword = newEncryptionPasswordTextField.text else { return }
        guard let encryptionPassword = UserDefaults.standard.string(forKey: "encryptionPassword") else { return }

        if encryptionPassword == currentpassword {
            UserDefaults.standard.set(newpassword, forKey: "encryptionPassword")
            UserDefaults.standard.set(currentpassword, forKey: "outdatedMasterPassword")

            self.performSegue(withIdentifier: "encrypt", sender: nil)
        } else {
            self.displayAlert(title: NSLocalizedString("whoops", comment: "An informal way of noting that something wrong happened."), message: NSLocalizedString("incorrectPassword", comment: "The entered master password is incorrect. Please check your entries and try again."), override: nil)
        }
    }

}
