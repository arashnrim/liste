//
//  OnboardingMenuViewController.swift
//  Liste
//
//  Created by Arash on 20/12/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Hero

class OnboardingMenuViewController: UIViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "encrypt" {
            let destination = segue.destination
            destination.hero.modalAnimationType = .slide(direction: .left)
        }
    }

}
