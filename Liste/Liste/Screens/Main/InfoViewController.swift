//
//  InfoViewController.swift
//  Liste
//
//  Created by Arash on 29/08/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: Actions
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
