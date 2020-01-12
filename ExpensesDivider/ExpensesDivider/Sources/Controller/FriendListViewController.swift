//
//  FriendListViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 28/11/2019.
//  Copyright © 2019 Banachowski Bartosz. All rights reserved.
//

import UIKit

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var myFriendListTableView: UITableView!
    let friendList = ["janek", "zdzislaw"]
    override func viewDidLoad() {
        super.viewDidLoad()
        myFriendListTableView.dataSource = self
        myFriendListTableView.delegate = self
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListItem", for: indexPath)

        cell.textLabel?.text = friendList[indexPath.row]
        return cell
    }
}
