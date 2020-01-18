//
//  Bill.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 18/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import Foundation

public struct Bill: Codable {
    var description: String
    var money: Decimal
    var debtorList: [Friend] = []
    
    init?(data: [String: Any]) {
        guard let debtorList = data["debtorList"] as? [[String: Any]],
            let money = data["money"] as? Double,
            let description = data["description"] as? String else {
                return nil
        }

        self.description = description
        self.money = Decimal(money)
        for index in 0..<debtorList.count {
            self.debtorList.append(Friend(data: debtorList[index])!)
        }
    }

    init?(description: String, money: Decimal, debtorList: [Friend]) {
        self.description = description
        self.money = money
        self.debtorList = debtorList
    }
}
