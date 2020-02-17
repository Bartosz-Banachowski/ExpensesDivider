//
//  AddFriendViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 03/12/2019.
//  Copyright © 2019 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class AddFriendViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    let friendManager = FriendManager()
    var loggedUser: User?
    var friendsList: [Friend] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        getExistingFriends()
        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func addFriendTapped(_ sender: Any) {
        let error = validateField()

        if let message = error {
            Utilities.showError(message, errorLabel)
        } else {
            let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let newFriend = Friend(uuid: DbConstants.defaultUserUUID,
                                   username: username!,
                                   email: email!,
                                   invitationStatus: .accepted)

            friendManager.addFriend(newFriend: newFriend!) { (error) in
                if error != nil {
                    Utilities.showError(NSLocalizedString("userSavingDataError", comment: "Error during saving new friend data"), self.errorLabel)
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    func validateField() -> String? {
        //check all field are full in
        let trimmedUsername = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedUsername == "" ||
            trimmedEmail == "" {
            return NSLocalizedString("emptyFieldsError", comment: "Empty fields error")
        }

        if Utilities.isEmailValid(trimmedEmail!) == false {
            return NSLocalizedString("validationEmailError", comment: "Email is not valid")
        }

        for friend in friendsList where friend.email == trimmedEmail {
            return NSLocalizedString("sameEmailsOfFriends", comment: "Same emails for two different friends")
        }
        return nil
    }

    func getExistingFriends() {
        friendManager.getFriends { (friendsList, error) in
            if let error = error {
                NSLog("Error getting friend list: \(error)")
            } else {
                self.friendsList.append(contentsOf: friendsList)
            }
        }
    }
}
