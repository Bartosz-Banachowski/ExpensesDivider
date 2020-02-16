//
//  GroupCell.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 14/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var accessLevelLabel: CustomLabel!

    func setGroup(group: Group, user: String) {
        groupNameLabel.text = group.groupName
        let accessLevel = getColorForAccessLevel(list: group.accessControlList, user: user)
        accessLevelLabel.textColor = accessLevel.0
        accessLevelLabel.text = accessLevel.1
    }

    private func getColorForAccessLevel(list: [String: AccessLevel], user: String) -> (UIColor, String) {
        let status = list.first { status -> Bool in
            status.key == user
        }

        switch status?.value {
        case .admin:
            return (UIColor(hexColor: "#ff5d6cff") ?? UIColor.systemGray, (status?.value.rawValue)!)
        case .member:
            return (UIColor(hexColor: "#ee8972ff") ?? UIColor.systemGray, (status?.value.rawValue)!)
        case .none:
            return (UIColor.green, (""))
        }
    }
}
