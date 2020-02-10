//
//  AccessUserList.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 07/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import Foundation

enum AccessLevel: String, Codable {
    case admin
    case member
}

struct AccessControlList: Codable {
    var accessControlList: [String: AccessLevel]

    init?(data: [String: Any]) {
        guard let accessControlList = data["AccessControlList"] as? [String: AccessLevel] else {
            return nil
        }

        self.accessControlList = accessControlList
    }

    init?(accessControlList: [String: AccessLevel]) {
        self.accessControlList = accessControlList
    }

    init?(members: [Friend], admin: String) {
        var data: [String: AccessLevel] = [:]
        for index in 0..<members.count where members[index].UUID != DbConstants.defaultUserUUID {
            data[members[index].UUID] =  AccessLevel.member
        }
        data[admin] = AccessLevel.admin
        self.accessControlList  = data
    }
}
