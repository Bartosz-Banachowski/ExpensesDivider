//
//  NotificationCenterViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 16/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import MessageUI

class NotificationCenterViewController: UIViewController, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var debtorListTableView: UITableView!
    @IBOutlet weak var sendButton: UIBarButtonItem!

    let userManager = UserManager()
    let notificationManager = NotificationManager()
    var groupInfo: Group!
    var billInfo: Bill!
    var debtorList: [GroupMember]!
    var selectedUserList: [GroupMember] = []
    var notifyCheckbox: Bool = false
    var emailCheckbox: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        debtorListTableView.delegate = self
        debtorListTableView.dataSource = self
        sendButton.target = self
        sendButton.action = #selector(sendNotificationsTapped)
    }

    @objc func sendNotificationsTapped() {
        //validation, description to bill, generate new translations, prosta edycja czegokolwiek
        if notifyCheckbox == true {
            for debtor in selectedUserList {
                notificationManager.getDeviceTokensForDebtor(debtor: debtor.email) { (tokens, error) in
                    if error != nil {
                        let errorAlert = AlertService.getErrorPopup(title: NSLocalizedString("ErrorTitle", comment: "error"),
                                                                    body: NSLocalizedString("ErrorBody", comment: "Error"))
                        self.present(errorAlert, animated: true, completion: nil)
                    } else {
                        for token in tokens {
                            self.sendPushNotification(to: token.deviceToken)
                        }
                    }
                }
            }
        }
        if emailCheckbox == true {
            sendEmail()
        }
    }

    @IBAction func sendNotificationsCheckbox(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { _ in
            sender.isSelected = !sender.isSelected
            self.notifyCheckbox = sender.isSelected
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                sender.transform = .identity
            }, completion: nil)
        })
     }

    @IBAction func sendEmailsCheckbox(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { _ in
            sender.isSelected = !sender.isSelected
            self.emailCheckbox = sender.isSelected
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                sender.transform = .identity
            }, completion: nil)
        })
    }

    func sendPushNotification(to token: String) {
        let url = NSURL(string: DbConstants.urlString)!
        let paramString: [String: Any] = ["to": token,
                                          "notification": ["title": userManager.loggedUserUsername + DbConstants.title,
                                                           "body": DbConstants.body + "\(groupInfo.groupName)/\(billInfo.description)"],
                                          "data": ["user": userManager.loggedUserUsername]]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(DbConstants.authAppKey, forHTTPHeaderField: "Authorization")

        let dataTask =  URLSession.shared.dataTask(with: request as URLRequest) { (info, _, error) in
            do {
                if let jsonInfo = info {
                    if let jsonDictionary  = try JSONSerialization.jsonObject(with: jsonInfo,
                                                                              options: JSONSerialization
                                                                                .ReadingOptions
                                                                                .allowFragments) as? [String: AnyObject] {
                        NSLog("Data received:\n\(jsonDictionary))")
                    }
                }
            } catch let error {
                NSLog("Error during posting request: \(error)")
            }
        }
        dataTask.resume()
    }

    func sendEmail() {
        var emails: [String] = []
        for debtor in selectedUserList {
            emails.append(debtor.email)
        }
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(emails)
            mail.setSubject("ExpensesDivider - Notification about debt")
            mail.setMessageBody("<p>Hello! </p> User \(userManager.loggedUserEmail) wants you to notify about your debt in group - \(groupInfo.groupName)/\(billInfo.description) " ,
                isHTML: true)
            present(mail, animated: true)
        } else {
            NSLog("Device is not set up to send emails")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debtorList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "debtorItem", for: indexPath)
        let member = debtorList[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = member.username
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUserList.append(debtorList[indexPath.row])
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedUserList.removeAll {$0.email == debtorList[indexPath.row].email}
        if tableView.indexPathsForSelectedRows == nil {
            selectedUserList = []
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Send notifications to picked debtors"
    }
}
