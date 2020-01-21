//
//  BillsOperations.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 20/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import Foundation
import UIKit

struct BillsOperations {

    static func getMoneySummaryColorLabel(bill: Bill) -> UILabel {
        let textLabel = UILabel()
        let debtors = Decimal(bill.debtorList.count)

        if bill.whoPaid == "You" {
            textLabel.textColor = .systemGreen
            let moneyBorrowed = (bill.money/debtors)*(debtors-1)
            textLabel.text = Utilities.currencyFormatter(currency: moneyBorrowed)
            return textLabel
        }

        textLabel.textColor = .red
        let moneyOwed = (bill.money/debtors)
        textLabel.text = Utilities.currencyFormatter(currency: moneyOwed)
        return textLabel
    }

    static func getMyBalance(bills: [Bill]) -> UILabel {
        let textLabel = UILabel()
        var balance: Decimal = 0
        var debtors: Decimal = 0
        var moneyBorrowed: Decimal = 0
        var moneyOwed: Decimal = 0

        for bill in bills {
            debtors = Decimal(bill.debtorList.count)
            if bill.whoPaid == "You" {
                moneyBorrowed += (bill.money/debtors)*(debtors-1)
            } else {
                moneyOwed += (bill.money/debtors)
            }
        }

        balance = moneyBorrowed - moneyOwed
        if balance < 0 {
            textLabel.textColor = .red
        } else if balance > 0 {
            textLabel.textColor = .systemGreen
        }
        textLabel.text = Utilities.currencyFormatter(currency: balance)
        return textLabel
    }

    static func calculateDebtForBill(whoPaid: String, money: Decimal, debtors: [Friend]) -> [Friend] {
        let numberOfDebtors = Decimal(debtors.count)
        let calculatedDebt = (money/numberOfDebtors)
        var calculatedDebtors: [Friend] = debtors
        for index in 0..<calculatedDebtors.count {
            calculatedDebtors[index].debt = calculatedDebt
        }
        return calculatedDebtors
    }
}
