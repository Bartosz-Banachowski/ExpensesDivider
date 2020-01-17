//
//  Group.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 14/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import Foundation

struct Group: Codable {
    var groupName: String
    var groupMembers: [Friend] = []

    init?(data: [String: Any]) {
        guard let groupMembers = data["groupMembers"] as? [[String: Any]],
            let groupName = data["groupName"] as? String else {
                return nil
        }

        self.groupName = groupName
        for index in 0..<groupMembers.count {
            self.groupMembers.append(Friend(data: groupMembers[index])!)
        }    
    }

    init?(groupName: String, groupMembers: [Friend]) {
        self.groupName = groupName
        self.groupMembers = groupMembers
    }
}
