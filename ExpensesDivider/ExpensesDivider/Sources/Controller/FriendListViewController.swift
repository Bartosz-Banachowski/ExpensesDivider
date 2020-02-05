//
//  FriendListViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 28/11/2019.
//  Copyright © 2019 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var myFriendListTableView: UITableView!
    var friendList: [Friend] = []
    let friendManager = FriendManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        myFriendListTableView.delegate = self
        myFriendListTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListeningForFriends()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningForFriends()
    }

    func deleteFriendFromDB(whichFriend index: Int) {
        let documentID = friendList[index].email
        friendManager.deleteFriend(who: documentID) { (bool, error) in
            if error != nil {
                //print error
            }
        }
    }

   // MARK: - Listeners
    func startListeningForFriends() {
        friendManager.getAllFriendsListener { friendList, error in
            if let error = error {
                // dobrze by bylo powiadomic uzytkownika o bledzie
                print("error: ", error)
            } else {
                self.friendList = friendList
                self.myFriendListTableView.reloadData()
            }
        }
    }

    func stopListeningForFriends() {
        friendManager.removeAllFriendsListener()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListItem", for: indexPath) as! FriendCell
        // swiftlint:enable force_cast

        let friend = friendList[indexPath.row]
        cell.setFriend(friend: friend)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteFriendFromDB(whichFriend: indexPath.row)
            friendList.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}
