//
//  HomeViewController.swift
//  ExpensesDivider
//
//  Created by Banachowski Bartosz on 12/09/2019.
//  Copyright © 2019 Banachowski Bartosz. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationManager = NotificationManager()
        notificationManager.registerForPushNotifications()
    }
}
