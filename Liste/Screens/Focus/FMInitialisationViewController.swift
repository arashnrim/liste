//
//  FMInitialisationViewController.swift
//  Liste
//
//  Created by Arash on 26/09/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import MSCircularSlider
import Hero

class FMInitialisationViewController: UIViewController, MSCircularSliderDelegate {

    // MARK: Outlets
    @IBOutlet weak var timerCircularSlider: MSCircularSlider!
    @IBOutlet weak var timeLabel: UILabel!

    // MARK: Properties
    var focusTime: Int = 0

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        self.timerCircularSlider.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "start" {
            let destination = segue.destination as! FMPreflightViewController
            destination.hero.modalAnimationType = .slide(direction: .left)
            destination.focusTime = self.focusTime
        }
    }

    // MARK: Circular Slider Protocols
    func circularSlider(_ slider: MSCircularSlider, valueChangedTo value: Double, fromUser: Bool) {
        let time = Int(round(value))
        let hours = Int(time / 60)
        let minutes = time - (hours * 60)
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
        }

        self.timeLabel.text = string
        self.focusTime = time
    }

    // MARK: Actions
    @IBAction func startButton(_ sender: ListeButton) {
        if focusTime > 0 {
            self.performSegue(withIdentifier: "start", sender: nil)
        }
    }

    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
