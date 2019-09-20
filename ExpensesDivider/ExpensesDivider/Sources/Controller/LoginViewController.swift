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
        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func loginTapped(_ sender: UIButton) {
    }

    @IBAction func forgotPassword(_ sender: UIButton) {
    }
}
