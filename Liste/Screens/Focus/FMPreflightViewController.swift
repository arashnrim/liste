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
    var screenBrightness: CGFloat = 0.0
    var tasks: [Task] = []
    var task: Task?
    var row: Int?

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Adds an observer that watches for changes in the device's orientation.
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)

        // Keeps track of the screen brightness for restoration when FMTimerViewController is interrupted.
        screenBrightness = UIScreen.main.brightness
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "start" {
            let destination = segue.destination as! FMTimerViewController
            destination.hero.modalAnimationType = .selectBy(presenting: .slide(direction: .left), dismissing: .slide(direction: .right))
            destination.focusTime = self.focusTime
            destination.tasks = self.tasks
            destination.task = self.task!
            destination.row = self.row!
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        // To mitigate consumption and (perhaps) prevent mishaps, the ViewController stops observing changes in the device's orientation when it moves into the background.
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    // MARK: Functions
    @objc func orientationChanged() {
        // Begins to observe changes in the device's orientation.
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        if UIDevice.current.orientation == .faceDown {
            self.performSegue(withIdentifier: "start", sender: nil)
        }
    }

    @IBAction func unwindToPreflight(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as! FMTimerViewController
        // Keeps track of the remaining time left when the user picked up their phone for re-use.
        let remainingTime = sourceViewController.focusTime
        self.focusTime = remainingTime
        // If brought back from FMTimerViewController, the screen's brightness is restored to its initial value.
        UIScreen.main.brightness = self.screenBrightness
    }
}
