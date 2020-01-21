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

    let database = Firestore.firestore()
    var billRef: CollectionReference!
    var billListener: ListenerRegistration?
    var groupInfo: Group!
    var billsList: [Bill] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        billRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("groups")
            .document(groupInfo!.groupName).collection("bills")
        billsListTableView.delegate = self
        billsListTableView.dataSource = self
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
        }
        if segue.destination is SettleUpBillViewController {
            let billVC = segue.destination as? SettleUpBillViewController
            billVC?.groupInfo = self.groupInfo
            if let index = self.billsListTableView.indexPathForSelectedRow {
                billVC?.billInfo = billsList[index.row]
            }
        }
    }

    func startListeningForBill() {
        billListener = billRef.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                NSLog("Error getting bills list: \(error)")
            } else {
                self.billsList = []
                for document in querySnapshot!.documents {
                    self.billsList.append(Bill(data: document.data())!)
                }
            }
            self.billsListTableView.reloadData()
            self.setupBalance()
        }
   }

   func stopListeningForBill() {
       billListener?.remove()
       billListener = nil
   }

    func getGroupInfo() {
        database.collection("users")
            .document((Auth.auth().currentUser?.uid)!)
            .collection("groups")
            .document(groupInfo!.groupName)
            .getDocument { (documentSnapshot, error) in
            if let error = error {
                NSLog("Error getting group member list: \(error)")
            } else {
                if let document = documentSnapshot?.data() {
                    self.groupInfo = Group(data: document)
                }
            }
        }
    }

    func setupGroupView() {
        groupNameLabel.text = groupInfo!.groupName
    }

    func setupBalance() {
        let summaryLabel = BillsOperations.getMyBalance(bills: billsList)
        balanceLabel.text = summaryLabel.text
        balanceLabel.textColor = summaryLabel.textColor
    }

    func deleteBillFromDB(whichBill index: Int) {
        let documentID = billsList[index].description
        database.collection("users").document((Auth.auth().currentUser?.uid)!)
            .collection("groups").document(groupInfo.groupName)
            .collection("bills").document(documentID).delete()
        NSLog("Succesfuly delete bill from the list - \(documentID)")
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
        cell.setBill(bill: bill)
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
