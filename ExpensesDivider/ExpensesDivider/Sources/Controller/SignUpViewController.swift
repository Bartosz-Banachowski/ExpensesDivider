//
//  SignUpViewController.swift
//  ExpensesDivider
//
//  Created by Banachowski Bartosz on 19/09/2019.
//  Copyright © 2019 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import Firebase

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

        if let message = error {
            Utilities.showError(message, errorLabel)
        } else {
            let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let login = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

            Auth.auth().createUser(withEmail: login!, password: password!) { (result, error) in
                if let error = error {
                    Utilities.showError(NSLocalizedString("userCreationError", comment: "Error during creating user"), self.errorLabel)
                    NSLog("User creation error: \(error.localizedDescription)")
                } else {
                    let database = Firestore.firestore()

                    database.collection("users").addDocument(data: ["username": username!, "email": login!, "uid": result!.user.uid],
                                                             completion: { (error) in
                        if error != nil {
                            Utilities.showError(NSLocalizedString("userSavingDataError", comment: "Error during saving user data"), self.errorLabel)
                            NSLog("User saving data error \(error.debugDescription)")
                        }

                        self.goToHome()
                    })
                }
            }
        }
    }

    func goToHome() {
        let homeStoryboard = UIStoryboard(name: Constants.Storyboard.homeStoryboard, bundle: Bundle.main)
        let homeVC = homeStoryboard.instantiateViewController(withIdentifier: Constants.Storyboard.homeVC) as? HomeViewController

        view.window?.rootViewController = homeVC
        view.window?.makeKeyAndVisible()
    }
}
