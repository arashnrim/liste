//
//  FMTimerViewController.swift
//  Liste
//
//  Created by Arash on 10/10/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import MSCircularSlider
import Hero
import UserNotifications

class FMTimerViewController: UIViewController {

    // MARK: Properties
    var focusTime: Double = 0.0
    var localFT: Double = 0.0
    var countdownTimer = Timer()
    var tasks: [Task] = []
    var task: Task?
    var row: Int?
    var disabled: Bool = false

    // MARK: Outlets
    @IBOutlet weak var timerSlider: MSCircularSlider!
    @IBOutlet weak var remainingTime: UILabel!

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        self.localFT = self.focusTime

        // This is quite a wonky workaround, but it works.
        // Basically, the total time of the Focus Mode period is stored in UserDefaults so that the value isn't lost when returned to FMPreflightViewController when the phone is picked up.
        // If there isn't any existing value in UserDefaults, it means that Focus Mode wasn't interrupted before; just to be safe, this value is stored here then.
        if UserDefaults.standard.value(forKey: "focusModeMaxTime") == nil {
            self.timerSlider.maximumValue = Double(self.focusTime * 60)
            UserDefaults.standard.setValue(Double(self.focusTime * 60), forKey: "focusModeMaxTime")
        } else {
            if let maxValue = UserDefaults.standard.value(forKey: "focusModeMaxTime") {
                self.timerSlider.maximumValue = maxValue as! Double
            }
        }

        // The main driving force of this view controller; a Timer that gradually counts down.
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)

        // Dims the screen to the dimmest it can go; this helps to encourage the user to focus on their tasks by making it harder to use their phone!
        UIScreen.main.brightness = CGFloat(0.0)
        // Begins to observe for changes in the device orientation; if faced up, the user is thrown back to FMPreflightViewController.
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)

        // Adds an observer that watches if the app goes into the background during this screen.
        // If that's the case, the user isn't using their time on their task!
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "success" {
            self.countdownTimer.invalidate()
            let destination = segue.destination as! FMSuccessViewController
            destination.hero.modalAnimationType = .slide(direction: .left)
            destination.tasks = self.tasks
            destination.task = self.task!
            destination.row = self.row!
        }
    }

    // MARK: Functions
    /// Counts down the time.
    @objc func countdown() {
        if self.localFT < 0 {
            self.disabled = true
            self.performSegue(withIdentifier: "success", sender: nil)
        } else {
            self.localFT -= 1/60
            self.timerSlider.currentValue = Double(self.localFT * 60)

            let hours = Int(self.localFT / 60)
            let minutes = Int(self.localFT) - (hours * 60)
            var string = ""

            if hours > 1 {
                string = "\(hours) \(NSLocalizedString("hours", comment: "Plural form of hour."))"
            } else if hours == 1 {
                string = "\(hours) \(NSLocalizedString("hour", comment: "Singular form of hour."))"
            } else {
                string = ""
            }

            if minutes == 1 {
                string += " \(minutes) \(NSLocalizedString("minute", comment: "Singular form of minute."))"
            } else if minutes > 1 {
                string += " \(minutes) \(NSLocalizedString("minutes", comment: "Plural form of minute."))"
            } else {
                string = ""
                let seconds = Int(round(60 * self.localFT))
                string = "\(seconds) \(NSLocalizedString("seconds", comment: "Plural form of second."))"
            }
            self.remainingTime.text = string
        }
    }

    @objc func orientationChanged() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        if UIDevice.current.orientation == .faceUp {
            if !(self.disabled) {
                self.performSegue(withIdentifier: "stop", sender: nil)
            }
            self.countdownTimer.invalidate()
        }
    }

    @objc func willResignActive(_ notification: Notification) {
        self.performSegue(withIdentifier: "stop", sender: nil)
        self.countdownTimer.invalidate()

        // Queues a notification to remind the user to get back to the app (and their task!)
        let centre = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("focusModeExitTitle", comment: "Wait, come back!")
        content.body = NSLocalizedString("focusModeExitMessage", comment: "You still have an ongoing Focus Mode session.")
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "focusModeExit", content: content, trigger: trigger)
        centre.add(request) { (error) in
            if let error = error {
                print("Error (while requesting notification): \(error.localizedDescription)")
            }
        }
    }
}
