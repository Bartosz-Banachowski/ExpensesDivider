//
//  Bill.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 18/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import Foundation
import FirebaseFirestore

public struct Bill: Codable {
    var description: String
    var money: Decimal
    var date: Date
    var whoPaid: String
    var debtorList: [GroupMember] = []

    init?(data: [String: Any]) {
        guard let debtorList = data["debtorList"] as? [[String: Any]],
            let money = data["money"] as? Double,
            let date = data["date"] as? Timestamp,
            let whoPaid = data["whoPaid"] as? String,
            let description = data["description"] as? String else {
                return nil
        }

        self.description = description
        self.money = Decimal(money)
        for index in 0..<debtorList.count {
            self.debtorList.append(GroupMember(data: debtorList[index])!)
        }
        self.date = date.dateValue()
        self.whoPaid = whoPaid
    }

    init?(description: String, money: Decimal, date: Date, whoPaid: String, debtorList: [GroupMember]) {
        self.description = description
        self.money = money
        self.date = date
        self.whoPaid = whoPaid
        self.debtorList = debtorList
    }
}
