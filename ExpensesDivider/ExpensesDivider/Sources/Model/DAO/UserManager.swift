//
//  UserManager.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 07/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class UserManager {

    let loggedUserID: String = Auth.auth().currentUser!.uid
    let loggedUserEmail: String = Auth.auth().currentUser!.email!
    var loggedUserUsername: String

    init() {
        loggedUserUsername = ""
        getLoggedUserUsername()
    }

    private func getLoggedUserUsername() {
        Firestore.firestore().collection(DbConstants.users).document(loggedUserID).getDocument { (docSnapshot, error) in
            if let error = error {
                NSLog("Error getting username from database: \(error)")
                return
            } else {
                if let doc = docSnapshot?.data()!["username"] as? String {
                    self.loggedUserUsername = doc
                }
            }
        }
    }
}
