//
//  BillCell.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 20/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit

class BillCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var billSummaryLabel: UILabel!
    @IBOutlet weak var whoPaidLabel: UILabel!
    var summaryLabel: UILabel?
    var whoPaidUsername: String?

    func setBill(bill: Bill, user: String) {
        setup(bill: bill, user: user)

        titleLabel.text = bill.description
        whoPaidLabel.text = ("Paid by: " + whoPaidUsername!)
        billSummaryLabel.textColor = summaryLabel?.textColor
        billSummaryLabel.text = summaryLabel?.text
    }

    private func setup(bill: Bill, user: String) {
        whoPaidUsername = bill.debtorList.first(where: { (debtor) -> Bool in
            debtor.email == bill.whoPaid
            })?.username
        summaryLabel = BillsOperations.getMoneySummaryColorLabel(bill: bill, currentLoggedUser: user)
    }
}
