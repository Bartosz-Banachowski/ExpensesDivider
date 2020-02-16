//
//  GroupViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 17/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var billsListTableView: UITableView!
    @IBOutlet weak var editGroupButton: CustomButton!

    var groupInfo: Group!
    var billManager: BillManager!
    var userManager: UserManager!
    var billsList: [Bill] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        billsListTableView.delegate = self
        billsListTableView.dataSource = self
        billManager = BillManager(UUID: groupInfo.UUID!)
        setupGroupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        startListeningForBill()
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopListeningForBill()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddBillViewController {
            let billVC = segue.destination as? AddBillViewController
            billVC?.groupInfo = self.groupInfo
            billVC?.billManager = self.billManager
        }
        if segue.destination is DetailedBillInfoViewController {
            let billVC = segue.destination as? DetailedBillInfoViewController
            billVC?.groupInfo = self.groupInfo
            billVC?.billManager = self.billManager
            billVC?.userManager = self.userManager
            if let index = self.billsListTableView.indexPathForSelectedRow {
                billVC?.billInfo = billsList[index.row]
            }
        }
    }

    func startListeningForBill() {
        billManager.getBillListener { (billList, error) in
            if error != nil {
                let errorAlert = AlertService.getErrorPopup(title: NSLocalizedString("ErrorTitle", comment: "error"),
                                                            body: NSLocalizedString("ErrorBody", comment: "Error"))
                self.present(errorAlert, animated: true, completion: nil)
            } else {
                self.billsList = billList
                self.billsListTableView.reloadData()
                self.setupBalance()
            }
        }
   }

   func stopListeningForBill() {
        billManager.removeBillListener()
   }

    func setupGroupView() {
        groupNameLabel.text = groupInfo!.groupName
    }

    func setupBalance() {
        let summaryLabel = BillsOperations.getMyBalance(bills: billsList, user: userManager.loggedUserEmail)
        balanceLabel.text = summaryLabel.text
        balanceLabel.textColor = summaryLabel.textColor
    }

    func deleteBillFromDB(whichBill index: Int) {
        let documentID = billsList[index].description
        billManager.deleteBill(which: documentID) { (error) in
            if error != nil {
                let errorAlert = AlertService.getErrorPopup(title: NSLocalizedString("ErrorTitle", comment: "error"),
                                                            body: NSLocalizedString("ErrorBody", comment: "error"))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
    }

    // MARK: - Group Table View data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return billsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillItem", for: indexPath) as! BillCell
        // swiftlint:enable force_cast

        let bill = billsList[indexPath.row]
        cell.setBill(bill: bill, user: userManager.loggedUserEmail)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteBillFromDB(whichBill: indexPath.row)
            billsList.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}
