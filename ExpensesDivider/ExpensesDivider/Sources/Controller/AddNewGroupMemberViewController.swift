//
//  AddNewGroupMemberViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 15/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

protocol AddMembersDelegate: AnyObject {
    func addMembers(members: [Friend])
}

class AddNewGroupMemberViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var friendListTableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    weak var delegate: AddMembersDelegate?
    var friendManager = FriendManager()
    var friendList: [Friend] = []
    var pickedMemberList: [Friend]!
    var selectedCells: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        friendListTableView.delegate = self
        friendListTableView.dataSource = self
        saveButton.target = self
        saveButton.action = #selector(saveMembers)
        getAllFriendList()
    }

    @objc func saveMembers() {
        pickedMemberList = []
        for cell in selectedCells {
            pickedMemberList.append(friendList[cell])
        }

        delegate?.addMembers(members: pickedMemberList)
    }

    func getAllFriendList() {
        friendManager.getFriends { (friendList, error) in
            if error != nil {
                let errorAlert = AlertService.getErrorPopup(title: NSLocalizedString("ErrorTitle", comment: "error"),
                                                            body: NSLocalizedString("ErrorBody", comment: "Error"))
                self.present(errorAlert, animated: true, completion: nil)
            } else {
                self.friendList = friendList
                self.friendListTableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberListItem", for: indexPath)

        let friend = friendList[indexPath.row]
        cell.textLabel?.text = friend.username
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCells.append(indexPath.row)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedCells.removeAll {$0 == indexPath.row}
        if tableView.indexPathsForSelectedRows == nil {
            selectedCells = []
        }
    }
}
