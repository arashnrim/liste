//
//  UITextField+Functionality.swift
//  Liste
//
//  Created by Arash Nur Iman on 26/06/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /**
     * Allows editing to end when any part of the screen is tapped outside the keyboard area.
     *
     * In essence, this function adds a `UITapGestureRecognizer` programatically that will end editing in the view when tapped.
     *
     * - Parameters:
     *      - completion: An optional closure to run after editing in the view has ended.
     */
    func dismissKeyboardOnTap(completion: (() -> Void)?) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        completion?()
    }
    
    /**
     * A supplementary function for `dismissKeyboardOnTap()`.
     *
     * This function calls for editing in the view to end; if needed, forcefully.
     */
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /**
     * Shifts the contents of the view upwards when the keyboard will be shown.
     *
     * This function monitors the status of the keyboard's size, and moves the view upwards when the keyboard is called and appears on-screen.
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    /**
     * Restores the contents of the view back as it was initially (converse action to  `keyboardWillShow()`.
     *
     * This function moves the view frame's vertical postion back to zero if the current view's frame
     */
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}
