//
//  FMInitialisationViewController.swift
//  Liste
//
//  Created by Arash on 26/09/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import MSCircularSlider

class FMInitialisationViewController: UIViewController, MSCircularSliderDelegate {

    // MARK: Outlets
    @IBOutlet weak var timerCircularSlider: MSCircularSlider!
    @IBOutlet weak var timeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.timerCircularSlider.delegate = self
    }

    func circularSlider(_ slider: MSCircularSlider, valueChangedTo value: Double, fromUser: Bool) {
        let time = Int(round(value))
        let hours = Int(time / 60)
        let minutes = time - (hours * 60)
        var string = ""
        print(time, hours, minutes)

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
    }

    // MARK: Actions
    @IBAction func startButton(_ sender: ListeButton) {
    }

    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
