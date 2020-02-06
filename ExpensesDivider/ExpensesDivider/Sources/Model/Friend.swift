//
//  Friend.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 12/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import Foundation

public struct Friend: Codable {
    var UUID: String
    let username: String
    let email: String
    var debt: Decimal
    var isAccepted: Bool

    init?(data: [String: Any]) {
        guard let uuid = data["UUID"] as? String,
        let username = data["username"] as? String,
        let email = data["email"] as? String,
        let debt = data["debt"] as? Double,
        let isAccepted = data["isAccepted"] as? Bool else {
               return nil
       }

        self.UUID = uuid
        self.username = username
        self.email = email
        self.debt = Decimal(debt)
        self.isAccepted = isAccepted
    }

    init?(uuid: String, username: String, email: String, debt: Decimal, isAccepted: Bool) {
        self.UUID = uuid
        self.username = username
        self.email = email
        self.debt = debt
        self.isAccepted = isAccepted
    }
}

extension Friend: Equatable {
    public static func == (lhs: Friend, rhs: Friend) -> Bool {
        return lhs.username == rhs.username && lhs.email == rhs.email
    }
}
