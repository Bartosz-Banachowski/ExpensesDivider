//
//  AddBillViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 17/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class AddBillViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var moneyTexTField: UITextField!
    @IBOutlet weak var withWhoSplitTableView: UITableView!
    @IBOutlet weak var saveNewBillButton: UIBarButtonItem!
    @IBOutlet weak var errorLabel: UILabel!
    let database = Firestore.firestore()
    var billRef: DocumentReference!
    var memberList: [Friend] = []
    var debtorList: [Friend] = []
    var groupName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        billRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("groups").document(groupName)
        saveNewBillButton.target = self
        saveNewBillButton.action = #selector(saveBill)
        withWhoSplitTableView.delegate = self
        withWhoSplitTableView.dataSource = self
    }

    @objc func saveBill() {
        let error = validateField()

        if let message = error {
            Utilities.showError(message, errorLabel)
        } else {
            let description = descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let money = moneyTexTField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let newBill = Bill(description: description!, money: 5, debtorList: debtorList)

            do {
                try billRef.collection("bills").document(newBill!.description).setData(from: newBill)
            } catch let error {
                Utilities.showError(NSLocalizedString("billSavingDataError", comment: "Error during saving new bill data"), self.errorLabel)
                NSLog("New bill saving data error \(error)")
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    func validateField() -> String? {
        //check all field are full in
        if descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "",  moneyTexTField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return NSLocalizedString("emptyFieldsError", comment: "Empty fields error")
        }

        return nil
    }

    //MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhoPaidItem", for: indexPath)
        cell.textLabel?.text = memberList[indexPath.row].username
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            memberList.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}
