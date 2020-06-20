//
//  AppDelegate.swift
//  Liste
//
//  Created by Arash Nur Iman on 01/10/19.
//  Copyright © 2019 Apprendre. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configures the Firebase library.
        FirebaseApp.configure()
        
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
        
        return true
    }
    
}
