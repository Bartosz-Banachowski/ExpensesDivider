//
//  NotificationToken.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 17/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import Foundation

struct NotificationToken: Codable {
    var UUID: String
    var deviceToken: String

    init?(data: [String: Any]) {
        guard let UUID = data["UUID"] as? String,
        let deviceToken = data["deviceToken"] as? String else {
            return nil
        }

        self.UUID = UUID
        self.deviceToken = deviceToken
    }

    init?(UUID: String, deviceToken: String) {
        self.UUID = UUID
        self.deviceToken = deviceToken
    }
}
