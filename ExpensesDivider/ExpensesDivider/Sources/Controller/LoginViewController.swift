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

    func validateField() -> String? {
        //check all field are full in
        if loginTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return NSLocalizedString("emptyFieldsError", comment: "Empty fields error")
        }

        if Utilities.isEmailValid(loginTextField.text!) == false {
            return NSLocalizedString("validationEmailError", comment: "Email is not valid")
        }

        return nil
    }

    @IBAction func loginTapped(_ sender: UIButton) {
//        Auth.auth().signIn(withEmail: "email@wp.pl", password: "zaq1@WSX")
//        self.goToHome()
        let error = validateField()

        if let message = error {
            Utilities.showError(message, errorLabel)
        } else {
            let login = loginTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

            Auth.auth().signIn(withEmail: login!, password: password!) { (_, error) in
                if let error = error {
                    Utilities.showError(NSLocalizedString("userLoginError", comment: "Error during log in user") + error.localizedDescription,
                                        self.errorLabel)
                    NSLog("User login error: \(error.localizedDescription)")
                } else {
                    NSLog("Login succesful")
                    self.goToHome()
                }
            }
        }
    }

    @IBAction func forgotPassword(_ sender: UIButton) {
        //TODO
    }

    func goToHome() {
        let homeStoryboard = UIStoryboard(name: Constants.Storyboard.homeStoryboard, bundle: Bundle.main)
        guard let homeVC = homeStoryboard.instantiateViewController(withIdentifier: Constants.Storyboard.homeVC) as? HomeViewController
            else {
                print("Could not find home view controller")
                return
            }

        view.window?.rootViewController = homeVC
        view.window?.makeKeyAndVisible()
    }
}
