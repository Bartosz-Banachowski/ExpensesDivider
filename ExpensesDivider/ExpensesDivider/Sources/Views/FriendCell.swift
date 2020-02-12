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
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var invitationStatusLabel: UILabel!

    func setFriend(friend: Friend) {
        usernameLabel.text = friend.username
        emailLabel.text = friend.email
        invitationStatusLabel.textColor = getColorForInvitationStatus(status: friend.invitationStatus)
        invitationStatusLabel.text = friend.invitationStatus.rawValue
    }

    private func getColorForInvitationStatus(status: InvitationStatus) -> UIColor {
        switch status {
        case .accepted:
            return .systemGreen
        case .checking:
            return .systemBlue
        case .pending:
            return .systemGray
        }
    }
}
