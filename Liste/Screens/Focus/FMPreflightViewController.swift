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

        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)

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
            print(self.focusTime)
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
        let sourceViewController = unwindSegue.source as! FMTimerViewController
        let remainingTime = sourceViewController.focusTime
        self.focusTime = remainingTime
        UIScreen.main.brightness = self.screenBrightness
    }
}
