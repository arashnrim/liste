//
//  SceneDelegate.swift
//  Liste
//
//  Created by Arash Nur Iman on 01/10/19.
//  Copyright © 2019 Apprendre. All rights reserved.
//

import UIKit
import Firebase

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // swiftlint:disable unused_optional_binding
        guard let _ = (scene as? UIWindowScene) else { return }

        // Performs conditional navigation on the status of currentUser.
        // If currentUser is not nil, then the app will start in the Main Storyboard.
        // Else, the app will start in the Auth Storyboard.
        Auth.auth().addStateDidChangeListener { (_, user) in
            if user != nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let rootViewController: UIViewController
                rootViewController = storyboard.instantiateViewController(identifier: "TasksViewController")
                self.window?.rootViewController = rootViewController
                self.window?.makeKeyAndVisible()
            } else {
                let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                let rootViewController: UIViewController
                rootViewController = storyboard.instantiateViewController(identifier: "WelcomeViewController")
                self.window?.rootViewController = rootViewController
                self.window?.makeKeyAndVisible()
            }
        }
    }

}
