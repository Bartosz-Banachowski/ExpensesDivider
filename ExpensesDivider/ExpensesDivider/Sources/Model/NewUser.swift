//
//  newUser.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 12/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import Foundation

public struct NewUser: Codable {
    let username: String
    let email: String
    let uid: String
}
