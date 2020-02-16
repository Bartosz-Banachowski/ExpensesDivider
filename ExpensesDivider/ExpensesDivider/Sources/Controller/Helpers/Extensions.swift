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

extension UIColor {
    public convenience init?(hexColor: String) {
        let red, green, blue, alpha: CGFloat
        if hexColor.hasPrefix("#") {
            let start = hexColor.index(hexColor.startIndex, offsetBy: 1)
            let hex = String(hexColor[start...])

            if hex.count == 8 {
                let scanner = Scanner(string: hex)
                var hexNum: UInt64 = 0

                if scanner.scanHexInt64(&hexNum) {
                    red = CGFloat((hexNum & 0xff000000) >> 24) / 255
                    green = CGFloat((hexNum & 0x00ff0000) >> 16) / 255
                    blue = CGFloat((hexNum & 0x0000ff00) >> 8) / 255
                    alpha = CGFloat(hexNum & 0x000000ff) / 255

                    self.init(red: red, green: green, blue: blue, alpha: alpha)
                    return
                }
            }
        }
        return nil
    }
}
