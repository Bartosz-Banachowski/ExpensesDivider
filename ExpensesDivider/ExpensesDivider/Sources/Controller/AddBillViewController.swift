//
//  AddBillViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 17/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class AddBillViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var moneyTexTField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var splitTextField: UITextField!
    @IBOutlet weak var whoPaidTextField: UITextField!
    @IBOutlet weak var withWhoSplitTableView: UITableView!
    @IBOutlet weak var saveNewBillButton: UIBarButtonItem!
    @IBOutlet weak var errorLabel: UILabel!
    let database = Firestore.firestore()
    var billRef: DocumentReference!
    var groupInfo: Group!
    var debtorList: [Friend] = []
    var whoPaidArray: [Friend] = []
    var existingBills: [Bill] = []

    private var datePicker: UIDatePicker?
    private var whoPaidPicker: UIPickerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        billRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("groups").document(groupInfo!.groupName)
        moneyTexTField.keyboardType = .decimalPad
        setupDatePicker()
        setupSplitType()
        setupWhoPaidPicker()
        getExistingBills()
        saveNewBillButton.target = self
        saveNewBillButton.action = #selector(saveBill)
        withWhoSplitTableView.delegate = self
        withWhoSplitTableView.dataSource = self
        whoPaidPicker?.delegate = self
        whoPaidPicker?.dataSource = self
    }

    func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(self.dateChanged(datePicker:)), for: .valueChanged)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        dateTextField.inputView = datePicker
    }

    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }

    @objc func viewTapped(gestureRecognizer: UIGestureRecognizer) {
        view.endEditing(true)
    }

    func setupSplitType() {
        splitTextField.frame.size.height = CGFloat(exactly: 50)!
    }

    func setupWhoPaidPicker() {
        whoPaidPicker = UIPickerView()
        whoPaidTextField.frame.size.height = CGFloat(exactly: 50)!
        whoPaidTextField.inputView = whoPaidPicker
        whoPaidArray = groupInfo.groupMembers
        whoPaidArray.append(Friend(uuid: Auth.auth().currentUser!.uid, username: "You", email: Auth.auth().currentUser!.email!, debt: Decimal(0))!)
    }

    @objc func saveBill() {
        let error = validateField()

        if let message = error {
            Utilities.showError(message, errorLabel)
        } else {
            let description = descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let money = (moneyTexTField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
            let date = datePicker?.date
            let whoPaid = whoPaidTextField.text
            debtorList.append(Friend(uuid: Auth.auth().currentUser!.uid, username: "You", email: Auth.auth().currentUser!.email!, debt: Decimal(0))!)
            let newBill = Bill(description: description!, money: Decimal(string: money)!, date: date!, whoPaid: whoPaid!,
                               debtorList: BillsOperations.calculateDebtForBill(whoPaid: whoPaid!,
                                                                                money: Decimal(string: money)!, debtors: debtorList))

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
        if descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            moneyTexTField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            dateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            whoPaidTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "who paid" ||
            debtorList.isEmpty == true {
            return NSLocalizedString("emptyFieldsError", comment: "Empty fields error")
        }

        for bill in existingBills where bill.description == descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            return NSLocalizedString("sameNameofGroups", comment: "Same bill's name")
        }
        return nil
    }

    private func getExistingBills() {
        billRef.collection("bills").getDocuments { (querySnapshot, error) in
           if let error = error {
               NSLog("Error getting bills list: \(error)")
           } else {
            self.existingBills = []
               for document in querySnapshot!.documents {
                   self.existingBills.append(Bill(data: document.data())!)
               }
           }
       }
   }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupInfo.groupMembers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhoPaidItem", for: indexPath)
        cell.textLabel?.text = groupInfo.groupMembers[indexPath.row].username
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debtorList.append(groupInfo.groupMembers[indexPath.row])
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        debtorList.removeAll {$0 == groupInfo.groupMembers[indexPath.row]}
        if tableView.indexPathsForSelectedRows == nil {
            debtorList = []
        }
    }

    // MARK: - Picker view data source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return whoPaidArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return whoPaidArray[row].username
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        whoPaidTextField.text = whoPaidArray[row].username
    }
}
