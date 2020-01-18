//
//  GroupViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 17/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {

    var groupName: String!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddBillViewController {
            let billVC = segue.destination as? AddBillViewController
            billVC?.groupName = self.groupName
        }
    }
}
