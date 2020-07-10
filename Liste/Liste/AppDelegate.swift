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
        
        // Performs conditional navigation on the status of currentUser.
        // If currentUser is not nil, then the app will start in the Main Storyboard.
        // Else, the app will start in the Auth Storyboard.
        let user = Auth.auth().currentUser
        if user != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController: UIViewController
            if #available(iOS 13.0, *) {
                rootViewController = storyboard.instantiateViewController(identifier: "Tasks")
            } else {
                rootViewController = storyboard.instantiateViewController(withIdentifier: "Tasks")
            }
            window?.rootViewController = rootViewController
            window?.makeKeyAndVisible()
        } else {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let rootViewController: UIViewController
            if #available(iOS 13.0, *) {
                rootViewController = storyboard.instantiateViewController(identifier: "Welcome")
            } else {
                rootViewController = storyboard.instantiateViewController(withIdentifier: "Welcome")
            }
            window?.rootViewController = rootViewController
            window?.makeKeyAndVisible()
        }
        
        return true
    }
    
}
