//
//  UIButton+Functionality.swift
//  Liste
//
//  Created by Arash Nur Iman on 26/06/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit

extension UIButton {

    /**
     * Changes the state and, if given, changes the title of the `UIButton`.
     *
     * This function uses `state`, a `Bool` value, and `text`, a `String?` value; based on the value of `state`, the button is either disabled or enabled - this change also includes an animation of the reduction or increase in `UIButton` alpha for a more visually-appealing design. If a `text` value is given, the title of the `UIButton` will also be changed.
     *
     * - Parameters:
     *      - state: A boolean value that describes the state the `UIButton` should be in.
     *      - text: (Optional) A string value to change the title of the `UIButton`.
     */
    func changeState(state: Bool, text: String?) {
        self.isEnabled = state

        if state == true {
            UIView.animate(withDuration: 0.5) {
                self.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.alpha = 0.5
            }
        }

        if let text = text {
            self.setTitle(text, for: .normal)
        }
    }

}
