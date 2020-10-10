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

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "start" {
            let destination = segue.destination as! FocusViewController
            destination.hero.modalAnimationType = .selectBy(presenting: .slide(direction: .left), dismissing: .slide(direction: .right))
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
}
