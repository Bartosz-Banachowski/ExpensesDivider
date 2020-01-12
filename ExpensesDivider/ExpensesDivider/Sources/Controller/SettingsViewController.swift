//
//  SettingsViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 12/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func logoutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            NSLog("Logout succesful")
        } catch let signOutError as NSError {
            NSLog("Error signing out: %@", signOutError)
        }

        guard let homeVC = UIStoryboard(name: Constants.Storyboard.loginStoryboard,
                                        bundle: Bundle.main).instantiateViewController(withIdentifier:
                                            Constants.Storyboard.loginVC) as? LoginViewController
            else {
                NSLog("Cannot presenting home view controller")
                return
            }
        homeVC.modalPresentationStyle = .fullScreen
        self.present(homeVC, animated: true, completion: nil)
    }
}
