//
//  AppDelegate.swift
//  Liste
//
//  Created by Arash Nur Iman on 01/10/19.
//  Copyright © 2019 Apprendre. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Configures the Firebase library.
        FirebaseApp.configure()

        // Performs conditional navigation on the status of currentUser.
        // If currentUser is not nil, then the app will start in the Main Storyboard.
        // Else, the app will start in the Auth Storyboard.
        Auth.auth().addStateDidChangeListener { (_, user) in
            if user != nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let rootViewController: UIViewController
                if #available(iOS 13.0, *) {
                    rootViewController = storyboard.instantiateViewController(identifier: "TasksViewController")
                } else {
                    rootViewController = storyboard.instantiateViewController(withIdentifier: "TasksViewController")
                }
                self.window?.rootViewController = rootViewController
                self.window?.makeKeyAndVisible()
            } else {
                let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                let rootViewController: UIViewController
                if #available(iOS 13.0, *) {
                    rootViewController = storyboard.instantiateViewController(identifier: "WelcomeViewController")
                } else {
                    rootViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController")
                }
                self.window?.rootViewController = rootViewController
                self.window?.makeKeyAndVisible()
            }
        }

        let centre = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert]
        centre.requestAuthorization(options: options) { (_, error) in
            if let error = error {
                print("Error (while requesting notification authorisation: \(error.localizedDescription)")
            }
        }

        return true
    }

}
