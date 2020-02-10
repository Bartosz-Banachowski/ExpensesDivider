//
//  UserManager.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 07/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class UserManager: NSObject {

    let currentLoggedUserID: String = Auth.auth().currentUser!.uid
}
