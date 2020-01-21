//
//  SettleUpBillViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 21/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit

class SettleUpBillViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var billNameLabel: UILabel!
    @IBOutlet weak var billDateLabel: UILabel!
    @IBOutlet weak var billMoney: UILabel!
    @IBOutlet weak var splitDetailsTableView: UITableView!
    var splitDetailsBills: [Group] = []
    var groupInfo: Group!
    var billInfo: Bill!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        splitDetailsTableView.delegate = self
        splitDetailsTableView.dataSource = self
    }

    func setupView() {
        billNameLabel.text = groupInfo.groupName
        billDateLabel.text = "Bill's date: \(Utilities.dateFormatter(date: billInfo.date))"
        billMoney.text = Utilities.currencyFormatter(currency: billInfo.money)
    }

    @IBAction func settleUpTapped(_ sender: Any) {
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return billInfo.debtorList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "billDetailsItem", for: indexPath)
        cell.textLabel?.text = billInfo.debtorList[indexPath.row].username
        cell.detailTextLabel?.text = Utilities.currencyFormatter(currency: billInfo.debtorList[indexPath.row].debt)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Split details:"
    }
}
