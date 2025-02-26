//
//  Utilities.swift
//  ExpensesDivider
//
//  Created by Banachowski Bartosz on 20/09/2019.
//  Copyright © 2019 Banachowski Bartosz. All rights reserved.
//

import Foundation
import UIKit

class Utilities {

    static func isPasswordValid(_ password: String) -> Bool {
        // Password has at least 1 char, special char, length 8
        let passwordFormula = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordFormula.evaluate(with: password)
    }

    static func isEmailValid(_ email: String) -> Bool {
        let emailFormula = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        return emailFormula.evaluate(with: email)
    }

    static func showError(_ message: String, _ errLabel: UILabel) {
        errLabel.text = message
        errLabel.alpha = 1
    }

    static func currencyFormatter(currency: Decimal) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "pl_PL")
        return currencyFormatter.string(for: currency)!
    }

    static func dateFormatter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "en_PL")
        return dateFormatter.string(from: date)
    }
}
