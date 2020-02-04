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
    @IBOutlet weak var personToSettleUpTextLabel: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    var billRef: DocumentReference!
    var groupInfo: Group!
    var billInfo: Bill!

    private var personToPay: UIPickerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        billRef = Firestore.firestore()
            .collection("users").document(Auth.auth().currentUser!.uid)
            .collection("groups").document(groupInfo!.groupName)
            .collection("bills").document(billInfo.description)
        setupWhoPaidPicker()
        personToPay?.delegate = self
        personToPay?.dataSource = self
    }

    @IBAction func settleUpTapped(_ sender: Any) {
        let error = validateField()

        if let message = error {
            Utilities.showError(message, errorLabel)
        } else {
            let debtorToPay = personToSettleUpTextLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let money = billMoneyTextLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            for index in 0..<billInfo.debtorList.count where billInfo.debtorList[index].username == debtorToPay {
                billInfo.debtorList[index].debt -= Decimal(string: money!)!
            }

            print("happy", billInfo.debtorList)
            do {
                try billRef.setData(from: billInfo)
            } catch let error {
                Utilities.showError(NSLocalizedString("billSavingDataError", comment: "Error during saving new bill data"), self.errorLabel)
                NSLog("New bill saving data error \(error)")
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
