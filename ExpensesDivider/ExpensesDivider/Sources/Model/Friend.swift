//
//  Friend.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 12/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import Foundation

public struct Friend: Codable {
    let username: String
    let email: String
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

extension Friend: Equatable {
    public static func == (lhs: Friend, rhs: Friend) -> Bool {
        return lhs.username == rhs.username && lhs.email == rhs.email
    }
}
