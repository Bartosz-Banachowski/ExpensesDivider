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
    static let bills = "bills"
    static let notificationTokens = "notificationTokens"

//fields name
    static let emailField = "email"
    static let UUIDField = "UUID"
    static let deviceTokenField = "deviceToken"
    static let accessControlList = "accessControlList"
    static let invitationStatusField = "invitationStatus"

//constants strings
    static let defaultUserUUID = ""
    static let noDebtStatus  = "0,00 zl"
    static let admin = "admin"
    static let member = "member"

//push notification
    static let title = "wants you to notify about our debt"
    static let body = "Group information: "
    static let urlString = "https://fcm.googleapis.com/fcm/send"
    static let authAppKey = "key=AAAA9aQ4lrM:APA91bGAk87-f7azyE4m99uk_q8GafFM0jjDXbwPWDADXLJsM9m3IEzG8dzN7Z9KdXlBscFsUoxs5ON2VySHaY1TFvKFyUt6ecL2RS6HNFyYKIQvIlCOzUQcx628OyC5aq_rh6aSTI1t"
}
