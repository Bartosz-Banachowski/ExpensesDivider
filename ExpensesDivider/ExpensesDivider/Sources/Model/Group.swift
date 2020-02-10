//
//  Group.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 14/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import Foundation

struct Group: Codable {
    var UUID: String?
    var groupName: String
    var groupMembers: [GroupMember] = []
    var accessControlList: [String: AccessLevel]?

    init?(data: [String: Any]) {
        guard let groupMembers = data["groupMembers"] as? [[String: Any]],
            let groupName = data["groupName"] as? String,
            let accessControlList = data["accessControlList"] as? [String: Any],
            let UUID = data["UUID"] as? String else {
                return nil
        }

        self.groupName = groupName
        for index in 0..<groupMembers.count {
            self.groupMembers.append(GroupMember(data: groupMembers[index])!)
        }
        self.accessControlList = AccessControlList(data: accessControlList)?.accessControlList
        self.UUID = UUID
    }

    init?(groupName: String, groupMembers: [GroupMember], accessControlList: AccessControlList) {
        self.groupName = groupName
        self.groupMembers = groupMembers
        self.accessControlList = accessControlList.accessControlList
    }
}
