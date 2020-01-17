//
//  AddFriendViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 03/12/2019.
//  Copyright © 2019 Banachowski Bartosz. All rights reserved.
//

import UIKit
import MessageUI
import Firebase

class AddFriendViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    let database = Firestore.firestore()
    var friendsRef: CollectionReference!
    var loggedUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        friendsRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("friends")
    }

    @IBAction func addFriendTapped(_ sender: Any) {
        let error = validateField()

        if let message = error {
            Utilities.showError(message, errorLabel)
        } else {
            let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let newFriend = Friend(username: username!, email: email!)

            do {
                try friendsRef.document(newFriend!.email).setData(from: newFriend)
            } catch let error {
                Utilities.showError(NSLocalizedString("userSavingDataError", comment: "Error during saving new friend data"), self.errorLabel)
                NSLog("New friend saving data error \(error)")
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    func validateField() -> String? {
        //check all field are full in
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return NSLocalizedString("emptyFieldsError", comment: "Empty fields error")
        }

        if Utilities.isEmailValid(emailTextField.text!) == false {
            return NSLocalizedString("validationEmailError", comment: "Email is not valid")
        }
        return nil
    }

    func sendEmail(_ recipient: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipient])
            mail.setSubject("Invitation to ExpensesDivider")
            mail.setMessageBody("<p>Hello! </p> User \(loggedUser?.email ?? "") has sent you an invitation to his friend list in ExpensesDivider",
                isHTML: true)
            present(mail, animated: true)
        } else {
            NSLog("Device is not set up to send emails")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
