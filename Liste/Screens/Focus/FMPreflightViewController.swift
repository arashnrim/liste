//
//  FMPreflightViewController.swift
//  Liste
//
//  Created by Arash on 10/10/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Hero

class FMPreflightViewController: UIViewController {

    // MARK: Properties
    var focusTime: Double = 0.0

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "start" {
            let destination = segue.destination as! FocusViewController
            destination.hero.modalAnimationType = .selectBy(presenting: .slide(direction: .left), dismissing: .slide(direction: .right))
            destination.focusTime = self.focusTime
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    // MARK: Functions
    @objc func orientationChanged() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        if UIDevice.current.orientation == .faceDown {
            self.performSegue(withIdentifier: "start", sender: nil)
        }
    }
    
    @IBAction func unwindToPreflight(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as! FocusViewController
        let remainingTime = sourceViewController.focusTime
        self.focusTime = remainingTime
    }
}
