//
//  Friend.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 12/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import Foundation

enum InvitationStatus: String, Codable {
    case accepted
    case pending
    case checking
}

struct Friend: Codable {
    var UUID: String
    let username: String
    let email: String
    var invitationStatus: InvitationStatus

    init?(data: [String: Any]) {
        guard let uuid = data["UUID"] as? String,
        let username = data["username"] as? String,
        let invitationStatus = data["invitationStatus"] as? String,
        let email = data["email"] as? String else {
            return nil
       }

        self.UUID = uuid
        self.username = username
        self.email = email
        self.invitationStatus = InvitationStatus(rawValue: invitationStatus)!
    }

    init?(uuid: String, username: String, email: String, invitationStatus: InvitationStatus) {
        self.UUID = uuid
        self.username = username
        self.email = email
        self.invitationStatus = invitationStatus
    }
}

extension Friend: Equatable {
    public static func == (lhs: Friend, rhs: Friend) -> Bool {
        return lhs.username == rhs.username && lhs.email == rhs.email
    }
}
