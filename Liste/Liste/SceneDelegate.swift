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
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // Performs conditional navigation on the condition of currentUser's status.
        let user = Auth.auth().currentUser
        if user != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController = storyboard.instantiateViewController(identifier: "View")
            window?.rootViewController = rootViewController
            window?.makeKeyAndVisible()
        } else {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let rootViewController = storyboard.instantiateViewController(identifier: "Welcome")
            window?.rootViewController = rootViewController
            window?.makeKeyAndVisible()
        }
    }

}
