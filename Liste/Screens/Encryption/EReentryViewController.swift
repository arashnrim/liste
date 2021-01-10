//
//  EReentryViewController.swift
//  Liste
//
//  Created by Arash on 20/12/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit

class EReentryViewController: UIViewController, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet weak var encryptionPasswordTextField: UITextField!
    @IBOutlet weak var incorrectLabel: UILabel!
    @IBOutlet weak var continueButton: ListeButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        encryptionPasswordTextField.delegate = self
        self.dismissKeyboardOnTap {
            guard let password = self.encryptionPasswordTextField.text else { return }
            if !password.isEmpty {
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

        if (UserDefaults.standard.string(forKey: "encryptionPassword")) != nil {
            self.incorrectLabel.isHidden = false
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Text Field Protocols
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let password = encryptionPasswordTextField.text else { return }
        if !password.isEmpty {
            continueButton.isEnabled = true
            UIView.animate(withDuration: 0.5) {
                self.continueButton.alpha = 1.0
            }
        } else {
            continueButton.isEnabled = false
            UIView.animate(withDuration: 0.5) {
                self.continueButton.alpha = 0.5
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(false)
        return false
    }

    // MARK: Actions
    @IBAction func continueButton(_ sender: Any) {
        guard let password = encryptionPasswordTextField.text else { return }
        UserDefaults.standard.set(password, forKey: "encryptionPassword")
        self.performSegue(withIdentifier: "complete", sender: nil)
    }

}
