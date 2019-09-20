//
//  SignUpViewController.swift
//  ExpensesDivider
//
//  Created by Banachowski Bartosz on 19/09/2019.
//  Copyright © 2019 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Foundation


class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }

    func validateField() -> String? {
        //check all field are full in
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            repeatPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return NSLocalizedString("emptyFieldsError", comment: "Empty fields error")
        }

        if Utilities.isEmailValid(emailTextField.text!) == false {
            return NSLocalizedString("validationEmailError", comment: "Email is not valid")
        }

        if Utilities.isPasswordValid(passwordTextField.text!) == false || Utilities.isPasswordValid(repeatPasswordTextField.text!) == false {
            return NSLocalizedString("validationPasswordError", comment: "Password is not valid" )
        }

        if passwordTextField.text! != repeatPasswordTextField.text! {
            return NSLocalizedString("passwordsAreNotEqualError", comment: "Passwords are not the same")
        }

        return nil
    }

    @IBAction func signUpTapped(_ sender: Any) {
        let error = validateField()

        if error != nil {
            errorLabel.text = error
            errorLabel.alpha = 1
        }
    }

}
