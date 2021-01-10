//
//  BeforeEncryptViewController.swift
//  Liste
//
//  Created by Arash on 21/12/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit
import Hero

class BeforeEncryptViewController: UIViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "encrypt" {
            let destination = segue.destination
            destination.hero.modalAnimationType = .slide(direction: .left)
        }
    }

}
