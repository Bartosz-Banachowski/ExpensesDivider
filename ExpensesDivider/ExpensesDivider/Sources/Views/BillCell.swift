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

    func setBill(bill: Bill) {
        titleLabel.text = bill.description
        whoPaidLabel.text = "Paid by: \(bill.whoPaid)"
        let summaryLabel = BillsOperations.getMoneySummaryColorLabel(bill: bill)
        billSummaryLabel.textColor = summaryLabel.textColor
        billSummaryLabel.text = summaryLabel.text
    }
}
