//
//  MenuViewController.swift
//  Liste
//
//  Created by Arash on 17/10/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Hero
import Firebase

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Outlets
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var listsTableView: UITableView!

    // MARK: Properties
    var lists: [String] = []
    var selectedList = ""

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        self.listsTableView.delegate = self
        self.listsTableView.dataSource = self

        // Reads the user's list name and updates the table view.
        retrieveDatabase { (data) in
            self.readListName(data: data)
            self.listsTableView.reloadData()
            UIView.animate(withDuration: 0.5) {
                self.loadingView.alpha = 0.0
            } completion: { (_) in
                self.loadingView.isHidden = true
            }
        }

        // Adds a swipe gesture recognizer to dismiss the menu when swiped left.
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeGestureRecognizer.direction = .left
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "menuUnwind" {
            let destination = segue.destination
            destination.hero.modalAnimationType = .uncover(direction: .left)
        } else if segue.identifier == "settings" {
            let destination = segue.destination
            destination.hero.modalAnimationType = .selectBy(presenting: .zoomOut, dismissing: .zoom)
        }
    }

    // MARK: Table View Protocols
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as! MenuTableViewCell

        cell.titleLabel.text = lists[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // swiftlint:disable:next todo
        // TODO: Since users are only bound to having one list per account, we can assume that this always works.
        // Even so, please work on the functionality ASAP!
        self.selectedList = lists[indexPath.row]
        self.performSegue(withIdentifier: "menuUnwind", sender: nil)
    }

    // MARK: Functions
    @objc func swiped() {
        self.dismiss(animated: true, completion: nil)
    }

    /**
     * Retrieves all user-related data in the Firestore database.
     *
     * - Parameters:
     *      - completion: A closure with a `[String:Any]` parameter (i.e., data fetched from the database).
     */
    func retrieveDatabase(completion: (([String: Any]) -> Void)?) {
        let database = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Warning: No authenticated user is found; attempting to recover by redirection.")
            self.showReauthenticationAlert()
            return
        }
        database.document("users/\(userID)").getDocument { (snapshot, error) in
            if let error = error {
                print("Error (fetching from Firebase database): \(error.localizedDescription)")
                self.displayAlert(title: "Uh oh.", message: error.localizedDescription, override: nil)
            } else {
                if let snapshot = snapshot {
                    let data = snapshot.data()
                    if let data = data {
                        completion?(data)
                    } else {
                        print("Warning: The snapshot data appears to be empty.")
                    }
                }
            }
        }
    }

    /**
     * Reads the user's list name.
     *
     * - Parameters:
     *      - data: A `[String:Any]` parameter, preferably the data retrieved from the Firestore database.
     */
    func readListName(data: [String: Any]) {
        if let listName = data["listName"] as? String {
            self.lists.append(listName)
        }
    }

}
