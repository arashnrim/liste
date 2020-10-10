//
//  FocusViewController.swift
//  Liste
//
//  Created by Arash on 10/10/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import MSCircularSlider

class FocusViewController: UIViewController {

    // MARK: Properties
    var focusTime: Double = 0.0
    var countdownTimer = Timer()

    // MARK: Outlets
    @IBOutlet weak var timerSlider: MSCircularSlider!
    @IBOutlet weak var remainingTime: UILabel!

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.value(forKey: "focusModeMaxTime") == nil {
            self.timerSlider.maximumValue = Double(self.focusTime * 60)
            UserDefaults.standard.setValue(Double(self.focusTime * 60), forKey: "focusModeMaxTime")
        } else {
            if let maxValue = UserDefaults.standard.value(forKey: "focusModeMaxTime") {
                self.timerSlider.maximumValue = maxValue as! Double
            }
        }
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)

        UIScreen.main.brightness = CGFloat(0.0)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        UserDefaults.standard.setValue(true, forKey: "focusModeStarted")
    }

    override func viewDidDisappear(_ animated: Bool) {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    // MARK: Functions
    @objc func countdown() {
        if self.focusTime < 0 {
            countdownTimer.invalidate()
        } else {
            self.focusTime -= 1/60
            print(focusTime)
            self.timerSlider.currentValue = Double(self.focusTime * 60)

            let hours = Int(focusTime / 60)
            let minutes = Int(focusTime) - (hours * 60)
            var string = ""

            if hours > 1 {
                string = "\(hours) hours"
            } else if hours == 1 {
                string = "\(hours) hour"
            } else {
                string = ""
            }

            if minutes == 1 {
                string += " \(minutes) minute"
            } else if minutes > 1 {
                string += " \(minutes) minutes"
            } else {
                string = ""
                let seconds = Int(round(60 * self.focusTime))
                string = "\(seconds) seconds"
            }
            self.remainingTime.text = string
        }
    }

    @objc func orientationChanged() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        if UIDevice.current.orientation == .faceUp {
            self.performSegue(withIdentifier: "stop", sender: nil)
            self.countdownTimer.invalidate()
        }
    }
}
