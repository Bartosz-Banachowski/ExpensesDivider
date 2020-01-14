//
//  FriendCell.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 14/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!

    func setFriend(friend: Friend) {
        usernameLabel.text = friend.username
    }
}
