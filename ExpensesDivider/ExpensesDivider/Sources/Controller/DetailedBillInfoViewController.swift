//
//  SettleUpBillViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 21/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class DetailedBillInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var billNameLabel: UILabel!
    @IBOutlet weak var billDateLabel: UILabel!
    @IBOutlet weak var billMoney: UILabel!
    @IBOutlet weak var splitDetailsTableView: UITableView!
    var userManager: UserManager!
    var billManager: BillManager!

    var splitDetailsBills: [Group] = []
    var groupInfo: Group!
    var billInfo: Bill!
    var detailedBill: Bill!

    override func viewDidLoad() {
        super.viewDidLoad()
        detailedBill = billInfo
        setupView()
        splitDetailsTableView.delegate = self
        splitDetailsTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        startListeningForDetailedBill()
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopListeningForDetailedBill()
    }

    func startListeningForDetailedBill() {
        billManager.getDetailedBillListener(UUID: billInfo.description) { (bill, error) in
            if error != nil {
                let errorAlert = AlertService.getErrorPopup(title: NSLocalizedString("ErrorTitle", comment: "error"),
                                                            body: NSLocalizedString("ErrorBody", comment: "Error"))
                self.present(errorAlert, animated: true, completion: nil)
            } else {
                self.detailedBill = bill
                self.splitDetailsTableView.reloadData()
            }
        }
    }

    func stopListeningForDetailedBill() {
        billManager.removeDetailedBillListener()
    }

    func setupView() {
        billNameLabel.text = billInfo.description
        billDateLabel.text = "Bill's date: \(Utilities.dateFormatter(date: billInfo.date))"
        billMoney.text = Utilities.currencyFormatter(currency: billInfo.money)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SettleUpBillViewController {
            let billVC = segue.destination as? SettleUpBillViewController
            billVC?.groupInfo = self.groupInfo
            billVC?.billInfo = self.billInfo
            billVC?.billManager = self.billManager
            billVC?.userManager = self.userManager
        }
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailedBill.debtorList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "billDetailsItem", for: indexPath)
        let debtor = detailedBill.debtorList[indexPath.row]
        cell.textLabel?.text = debtor.username
        cell.detailTextLabel?.textColor = .systemRed
        cell.detailTextLabel?.text = Utilities.currencyFormatter(currency: debtor.debt)
        if cell.detailTextLabel?.text == DbConstants.noDebtStatus || debtor.email == billInfo.whoPaid {
            cell.detailTextLabel?.textColor = .systemGreen
        }
        if debtor.email == userManager.loggedUserEmail {
            cell.backgroundColor = .lightGray
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var whoPaidUsername: String = billInfo.whoPaid
        for debtor in billInfo.debtorList where debtor.email == billInfo.whoPaid {
            whoPaidUsername = debtor.username
        }
        return "Details - Paid by:   \(whoPaidUsername)"
    }
}
