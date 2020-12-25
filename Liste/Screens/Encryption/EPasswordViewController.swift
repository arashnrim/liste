//
//  EPasswordViewController.swift
//  Liste
//
//  Created by Arash on 20/12/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Firebase

class EPasswordViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Overrides
    @IBOutlet weak var masterPasswordTextField: UITextField!
    @IBOutlet weak var continueButton: ListeButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        masterPasswordTextField.delegate = self
        self.dismissKeyboardOnTap {
            guard let password = self.masterPasswordTextField.text else { return }
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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Text Field Protocols
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let password = masterPasswordTextField.text else { return }
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

    // MARK: - Actions
    @IBAction func continueButton(_ sender: Any) {
        guard let password = masterPasswordTextField.text else { return }
        UserDefaults.standard.set(password, forKey: "masterPassword")

        let database = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Warning: No authenticated user is found; attempting to recover by redirection.")
            self.showReauthenticationAlert()
            return
        }
        database.document("users/\(userID)").getDocument { (snapshot, error) in
            if let error = error {
                self.displayAlert(title: NSLocalizedString("errorOccurred", comment: "An error occurred."), message: error.localizedDescription, override: nil)
            } else {
                if let snapshot = snapshot {
                    let data = snapshot.data()
                    if let data = data {
                        if let configured = data["configured"] as? Bool {
                            if !(configured) {
                                self.performSegue(withIdentifier: "onboard", sender: nil)
                            } else {
                                let database = Firestore.firestore()
                                guard let userID = Auth.auth().currentUser?.uid else {
                                    print("Warning: No authenticated user is found; attempting to recover by redirection.")
                                    self.showReauthenticationAlert()
                                    return
                                }

                                database.document("users/\(userID)").updateData(["encrypted": true]) { (error) in
                                    if let error = error {
                                        self.displayAlert(title: NSLocalizedString("errorOccurred", comment: "An error occurred."), message: error.localizedDescription, override: nil)
                                    } else {
                                        self.performSegue(withIdentifier: "encrypt", sender: nil)
                                    }
                                }
                            }
                        }
                    } else {
                        print("Warning: The snapshot data appears to be empty.")
                    }
                }
            }
        }
    }

    @IBAction func backButton(_ sender: Any) {
        self.hero.dismissViewController()
    }

}
