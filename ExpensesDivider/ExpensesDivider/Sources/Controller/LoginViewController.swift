//
//  LoginViewController.swift
//  ExpensesDivider
//
//  Created by Banachowski Bartosz on 18/07/2019.
//  Copyright © 2019 Banachowski Bartosz. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func validateField() -> String? {

        //check all field are full in
        if loginTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {

            return NSLocalizedString("emptyFieldsError", comment: "Empty fields error")
        }

        return nil
    }

    @IBAction func loginTapped(_ sender: UIButton) {
        errorLabel.alpha = 1
        errorLabel.text = validateField()

    }

    @IBAction func forgotPassword(_ sender: UIButton) {
    }
}
