//
//  AboutViewController.swift
//  Liste
//
//  Created by Arash on 29/10/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    // MARK: Actions
    @IBAction func sourceCodeButton(_ sender: Any) {
        if let url = URL(string: "https://github.com/arashnrim/Liste") {
            UIApplication.shared.open(url)
        }
    }

}
