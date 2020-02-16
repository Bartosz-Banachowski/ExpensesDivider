//
//  CustomTextField.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 13/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
}
