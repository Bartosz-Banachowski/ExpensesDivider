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

    static func getMoneySummaryColorLabel(bill: Bill, currentLoggedUser: String) -> UILabel {
        let textLabel = UILabel()

        if bill.whoPaid == currentLoggedUser {
            textLabel.textColor = .systemGreen
            var moneyBorrowed = Decimal(0)
            for debtor in bill.debtorList where debtor.email != currentLoggedUser {
                moneyBorrowed += debtor.debt
            }
            textLabel.text = Utilities.currencyFormatter(currency: moneyBorrowed)
            return textLabel
        }

        textLabel.textColor = .red
        var moneyOwed = Decimal(0)
        for debtor in bill.debtorList where debtor.email == currentLoggedUser {
            moneyOwed = debtor.debt
        }
        textLabel.text = Utilities.currencyFormatter(currency: moneyOwed)
        return textLabel
    }

    static func getMyBalance(bills: [Bill], user: String) -> UILabel {
        let textLabel = UILabel()
        var balance: Decimal = 0
        var moneyBorrowed: Decimal = 0
        var moneyOwed: Decimal = 0
//TODO BALANCE
        for bill in bills {
            if bill.whoPaid == user {
                for debtor in bill.debtorList where debtor.username != user {
                    moneyBorrowed += debtor.debt
                }
            } else {
                for debtor in bill.debtorList where debtor.username == user {
                    moneyOwed += debtor.debt
                }
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

    static func calculateDebtForBill(whoPaid: String, money: Decimal, debtors: [GroupMember]) -> [GroupMember] {
        let numberOfDebtors = Decimal(debtors.count)
        let calculatedDebt = (money/numberOfDebtors)
        var calculatedDebtors: [GroupMember] = debtors
        for index in 0..<calculatedDebtors.count {
            calculatedDebtors[index].debt = calculatedDebt
        }
        return calculatedDebtors
    }
}
