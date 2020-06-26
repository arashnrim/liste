//
//  UIButton+Functionality.swift
//  Liste
//
//  Created by Arash Nur Iman on 26/06/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit

extension UIButton {
    
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
