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
    
    func setGroup(group: Group) {
        groupNameLabel.text = group.groupName
    }
}
