//
//  EEncryptingViewController.swift
//  Liste
//
//  Created by Arash on 20/12/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Firebase
import RNCryptor

class EEncryptingViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!

    // MARK: Properties
    var newPassword: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            loadingView.style = .medium
        } else {
            loadingView.style = .gray
        }

        if let newPassword = newPassword {
            UserDefaults.standard.setValue(newPassword, forKey: "encryptionPassword")
        }

        statusLabel.text = NSLocalizedString("connectingToDatabase", comment: "Connecting to database...")
        let database = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Warning: No authenticated user is found; attempting to recover by redirection.")
            self.showReauthenticationAlert()
            return
        }
        statusLabel.text = NSLocalizedString("retrievingData", comment: "Retrieving data...")
        database.document("users/\(userID)").getDocument { (snapshot, error) in
            if let error = error {
                self.displayAlert(title: NSLocalizedString("errorOccurred", comment: "An error occurred."), message: error.localizedDescription, override: nil)
            } else {
                if let snapshot = snapshot {
                    let data = snapshot.data()
                    if let data = data {
                        self.statusLabel.text = NSLocalizedString("encryptingData", comment: "Encrypting data...")
                        let encryptedData = self.encryptData(unencryptedData: data)

                        self.statusLabel.text = NSLocalizedString("uploadingChanges", comment: "Uploading changes...")
                        self.updateDatabase(encryptedData: encryptedData)
                    } else {
                        print("Warning: The snapshot data appears to be empty.")
                    }
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "complete" {
            let destination = segue.destination
            destination.hero.modalAnimationType = .uncover(direction: .down)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func encryptData(unencryptedData: [String: Any]) -> [String: Any] {
        guard let password = UserDefaults.standard.string(forKey: "encryptionPassword") else { return [:] }

        var encryptedData = [String: Any]()
        for item in unencryptedData {
            if let value = item.value as? String {
                guard let valueData = value.data(using: .utf8) else { return [:] }
                let cipheredData = RNCryptor.encrypt(data: valueData, withPassword: password)
                encryptedData[item.key] = cipheredData
            } else {
                if item.key == "tasks" {
                    if let tasks: [String: Any] = item.value as? [String: [String: Any]] {
                        var encryptedTasks = [String: Any]()
                        for task in tasks {
                            var encryptedTask = [String: Any]()
                            let details = task.value as! [String: Any]
                            // Encrypts the task name and description.
                            for detail in details {
                                if detail.key == "taskName" || detail.key == "description"{
                                    if let value = detail.value as? String {
                                        guard let valueData = value.data(using: .utf8) else { return [:] }
                                        let cipheredData = RNCryptor.encrypt(data: valueData, withPassword: password)
                                        encryptedTask[detail.key] = cipheredData
                                    } else if let value = detail.value as? Data {
                                        let previousPassword = UserDefaults.standard.string(forKey: "outdatedMasterPassword")!
                                        var decryptedValue = Data()
                                        do {
                                            decryptedValue = try RNCryptor.decrypt(data: value, withPassword: previousPassword)
                                        } catch {
                                            self.displayAlert(title: NSLocalizedString("encryptionFailedTitle", comment: "Encryption failed."), message: NSLocalizedString("encryptionFailedMessage", comment: "We couldn't decrypt your current encrypted data. You may need to reset your password and discard your tasks entirely.")) { (alert) in
                                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                                    self.performSegue(withIdentifier: "complete", sender: nil)
                                                }))
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                        }
                                        let cipheredData = RNCryptor.encrypt(data: decryptedValue, withPassword: password)
                                        encryptedTask[detail.key] = cipheredData
                                    }
                                } else {
                                    encryptedTask[detail.key] = detail.value
                                }
                            }
                            encryptedTasks[task.key] = encryptedTask
                        }
                        encryptedData["tasks"] = encryptedTasks
                    }
                } else if item.key == "listName" {
                    if let listName = item.value as? String {
                        encryptedData["listName"] = listName
                    } else if let listData = item.value as? Data {
                        let previousPassword = UserDefaults.standard.string(forKey: "outdatedMasterPassword")!
                        var decryptedValue = Data()
                        do {
                            decryptedValue = try RNCryptor.decrypt(data: listData, withPassword: previousPassword)
                        } catch {
                            self.displayAlert(title: NSLocalizedString("encryptionFailedTitle", comment: "Encryption failed."), message: NSLocalizedString("encryptionFailedMessage", comment: "We couldn't decrypt your current encrypted data. You may need to reset your password and discard your tasks entirely.")) { (alert) in
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                    self.performSegue(withIdentifier: "complete", sender: nil)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        let cipheredData = RNCryptor.encrypt(data: decryptedValue, withPassword: password)
                        encryptedData[item.key] = cipheredData
                    }
                } else {
                    encryptedData[item.key] = item.value
                }
            }
        }
        encryptedData["encrypted"] = true
        print(encryptedData)
        return encryptedData
    }

    func updateDatabase(encryptedData: [String: Any]) {
        let database = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Warning: No authenticated user is found; attempting to recover by redirection.")
            self.showReauthenticationAlert()
            return
        }

        database.document("users/\(userID)").updateData(encryptedData) { (error) in
            self.statusLabel.text = NSLocalizedString("completingEncryption", comment: "Completing encryption...")
            if let error = error {
                self.displayAlert(title: NSLocalizedString("errorOccurred", comment: "An error occurred"), message: error.localizedDescription) { (alert) in
                    alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "An affirmative statement."), style: .default, handler: { (_) in
                        self.performSegue(withIdentifier: "complete", sender: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                self.displayAlert(title: NSLocalizedString("encryptionSuccessfulTitle", comment: "Encryption successful."), message: NSLocalizedString("encryptionSuccessfulMessage", comment: "Your data is now encrypted and more secure. Please restart the app for decryption to take place.")) { (alert) in
                    UserDefaults.standard.removeObject(forKey: "encryptionPassword")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

}
