//
//  Extensions.swift
//  ExpensesDivider
//
//  Created by Banachowski Bartosz on 20/09/2019.
//  Copyright © 2019 Banachowski Bartosz. All rights reserved.
//

import UIKit
import os

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
