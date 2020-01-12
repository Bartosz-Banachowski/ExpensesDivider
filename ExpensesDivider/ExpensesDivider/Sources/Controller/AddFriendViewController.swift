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

    var loggedUsername: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        loggedUsername = Auth.auth().currentUser!
    }

    @IBAction func addFriendTapped(_ sender: Any) {
        sendEmail(emailTextField.text!)
        dismiss(animated: true)

        //pobierz wartosci z text field
            //sprawdz czy ktos o odpowiedniej nazwie uzytkownika i emailu istnieje w bazie danych
            //jesli TAK wyslij zaproszenie do grupy znajomychw aplikacji
            //jesli nie wyslij zaproszenie do sciagniecia aplikacji i stworzenia konta
        //
    }

    func sendEmail(_ recipient: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipient])
            mail.setSubject("Invitation to ExpensesDivider")
            mail.setMessageBody("<p>Hello! </p> User \(loggedUsername?.email ?? "") has sent you an invitation to his friend list in ExpensesDivider",
                isHTML: true)
            present(mail, animated: true)
        } else {
            NSLog("Device is not set up to send emails")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        print("RTSTSTSFS")

        if let _ = error {
            controller.dismiss(animated: true)
        }
        
        print("RTSTSTSFS")
        controller.dismiss(animated: true)
    }
}
