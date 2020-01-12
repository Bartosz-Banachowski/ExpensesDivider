//
//  CustomLabel.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 17/12/2019.
//  Copyright © 2019 Banachowski Bartosz. All rights reserved.
//

import UIKit

class CustomLabel: UILabel {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.masksToBounds = true
            layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
            layer.borderColor = UIColor.green.cgColor
        }
    }

    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
}
