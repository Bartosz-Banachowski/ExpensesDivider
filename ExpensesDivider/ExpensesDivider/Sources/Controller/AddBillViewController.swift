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
    var billManager: BillManager!
    var groupInfo: Group!
    var debtorList: [GroupMember] = []
    var whoPaidArray: [GroupMember] = []
    var existingBills: [Bill] = []
    var whoPaidEmail: String?

    private var datePicker: UIDatePicker?
    private var whoPaidPicker: UIPickerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        moneyTexTField.keyboardType = .decimalPad
        setupDatePicker()
        setupSplitType()
        setupWhoPaidPicker()
        getExistingBills()
        saveNewBillButton.target = self
        saveNewBillButton.action = #selector(saveBillTapped)
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
        tapGesture.cancelsTouchesInView = false
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
    }

    @objc func saveBillTapped() {
        let error = validateField()

        if let message = error {
            Utilities.showError(message, errorLabel)
        } else {
            let description = (descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
            let money = (moneyTexTField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
            let date = (datePicker?.date)!

            let newBill = Bill(description: description,
                               money: Decimal(string: money)!,
                               date: date,
                               whoPaid: whoPaidEmail!,
                               debtorList: BillsOperations.calculateDebtForBill(whoPaid: whoPaidEmail!,
                                                                                money: Decimal(string: money)!,
                                                                                debtors: debtorList))
            billManager.addBill(newBill: newBill!) { (error) in
                if error != nil {
                    Utilities.showError(NSLocalizedString("billSavingDataError", comment: "Error during saving new bill data"), self.errorLabel)
                }
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

        if let dotValidation = moneyTexTField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            var dotCount = 0
            for dot in dotValidation where dot.isPunctuation == true {
                dotCount += 1
            }
            if dotCount > 1 {
                return NSLocalizedString("TooMuchDotsInMoneyFieldError", comment: "There should be only 1 dot")
            }
        }

        if let charValidation = moneyTexTField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            let charFlag = charValidation.contains(where: { (character) -> Bool in
                character.isLetter
            })
            if charFlag == true {
                return NSLocalizedString("MoneyFieldError", comment: "There should be only numbers")
            }
        }

        for bill in existingBills where bill.description == descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            return NSLocalizedString("sameNameofGroups", comment: "Same bill's name")
        }
        return nil
    }

    private func getExistingBills() {
        billManager.getBills { (existingBills, error) in
            if error == nil {
                self.existingBills = existingBills
            }
        }
   }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupInfo.groupMembers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhoPaidItem", for: indexPath)
        let member = groupInfo.groupMembers[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = member.username
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debtorList.append(groupInfo.groupMembers[indexPath.row])
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        debtorList.removeAll {$0.email == groupInfo.groupMembers[indexPath.row].email}
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
        whoPaidEmail = whoPaidArray[row].email
    }
}
