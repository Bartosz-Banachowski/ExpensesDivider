//
//  SettleUpBillViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 21/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class SettleUpBillViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var billNameLabel: UILabel!
    @IBOutlet weak var billMoneyTextLabel: UITextField!
    @IBOutlet weak var currentDebtLabel: UILabel!
    @IBOutlet weak var personToSettleUpTextLabel: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    var billManager: BillManager!
    var userManager: UserManager!
    var groupInfo: Group!
    var billInfo: Bill!

    private var personToPay: UIPickerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWhoPaidPicker()
        setupView()
        personToPay?.delegate = self
        personToPay?.dataSource = self
    }

    func setupView() {
        billNameLabel.text = billInfo.description
        if let debt = billInfo.debtorList.first(where: { debtor -> Bool in
            debtor.email == userManager.loggedUserEmail
        })?.debt {
            currentDebtLabel.textColor = .darkGray
            currentDebtLabel.text = Utilities.currencyFormatter(currency: debt)
        }
    }

    @IBAction func settleUpTapped(_ sender: Any) {
        let error = validateField()

        if let message = error {
            Utilities.showError(message, errorLabel)
        } else {
            let debtorToPay = personToSettleUpTextLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let money = billMoneyTextLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            setupBillInfo(money: money!, debtorToPay: debtorToPay!)

            billManager.updateBill(which: billInfo) { (error) in
                if error != nil {
                    Utilities.showError(NSLocalizedString("billSavingDataError", comment: "Error during saving new bill data"), self.errorLabel)
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    func validateField() -> String? {
    //check all field are full in
        if billMoneyTextLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            personToSettleUpTextLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "choose person to settle up" {
                return NSLocalizedString("emptyFieldsError", comment: "Empty fields error")
        }
        if let dotValidation = billMoneyTextLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            var dotCount = 0
            for dot in dotValidation where dot.isPunctuation == true {
                dotCount += 1
            }
            if dotCount > 1 {
                return NSLocalizedString("TooMuchDotsInMoneyFieldError", comment: "There should be only 1 dot")
            }
        }
        if let charValidation = billMoneyTextLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            let charFlag = charValidation.contains(where: { (character) -> Bool in
                character.isLetter
            })
            if charFlag == true {
                return NSLocalizedString("MoneyFieldError", comment: "There should be only numbers")
            }
        }
        return nil
    }

    @objc func viewTapped(gestureRecognizer: UIGestureRecognizer) {
        view.endEditing(true)
    }

    func setupWhoPaidPicker() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        billNameLabel.text = billInfo.description
        personToPay = UIPickerView()
        personToSettleUpTextLabel.frame.size.height = CGFloat(exactly: 50)!
        personToSettleUpTextLabel.inputView = personToPay
    }

    private func setupBillInfo(money: String, debtorToPay: String) {
        for index in 0..<billInfo.debtorList.count where billInfo.debtorList[index].email == billInfo.whoPaid {
            billInfo.debtorList[index].debt += Decimal(string: money)!
        }
        for index in 0..<billInfo.debtorList.count where billInfo.debtorList[index].username == debtorToPay {
            billInfo.debtorList[index].debt -= Decimal(string: money)!
        }
    }

    // MARK: - Picker view data source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return billInfo.debtorList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return billInfo.debtorList[row].username
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        personToSettleUpTextLabel.text = billInfo.debtorList[row].username
    }
}
