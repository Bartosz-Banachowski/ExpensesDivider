//
//  DbConstants.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 01/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import Foundation

struct DbConstants {
//database collection reference
    static let users = "users"
    static let friends = "friends"
    static let groups = "groups"

//fields name
    static let emailField = "email"
    static let accessControlList = "accessControlList"
    static let isAcceptedField = "isAccepted"

//constants strings
    static let defaultUserUUID = ""
    static let admin = "admin"
    static let member = "member"
}
