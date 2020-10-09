//
//  OnboardingViewController.swift
//  Liste
//
//  Created by Arash Nur Iman on 18/07/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Firebase
import Hero

class OnboardingViewController: UIViewController {

    // MARK: Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "return" {
            let destination = segue.destination
            destination.hero.modalAnimationType = .slide(direction: .down)
        }
    }

    // MARK: Functions
    /**
     * Updates the user's `configured` state to `true`.
     *
     * - Parameters:
     *      - completion: A closure to run after the update.
     */
    func updateUserStatus(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Warning: No authenticated user is found; attempting to recover by redirection.")
            self.showReauthenticationAlert()
            return
        }

        let database = Firestore.firestore()
        database.document("users/\(userID)").updateData(["configured": true]) { (error) in
            if let error = error {
                print("Error (while changing user configuration status): \(error.localizedDescription)")
                self.displayAlert(title: "Whoops.", message: error.localizedDescription, override: nil)
            } else {
                completion()
            }
        }
    }

    // MARK: Actions
    @IBAction func finishButton(_ sender: ListeButton) {
        updateUserStatus {
            self.performSegue(withIdentifier: "return", sender: nil)
        }
    }

}
