//
//  GroupMember.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 07/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import Foundation

struct GroupMember: Codable {
    var username: String
    var email: String
    var debt: Decimal

    init?(data: [String: Any]) {
        guard let username = data["username"] as? String,
        let email = data["email"] as? String,
        let debt = data["debt"] as? Double else {
               return nil
       }

        self.username = username
        self.email = email
        self.debt = Decimal(debt)
    }

    init?(username: String, email: String, debt: Decimal) {
        self.username = username
        self.email = email
        self.debt = debt
    }
}
