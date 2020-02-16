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
        friendManager.declineInvtitation(who: documentID) { (error) in
            if error != nil {
                let errorAlert = AlertService.getErrorPopup(title: NSLocalizedString("ErrorTitle", comment: "error"),
                                                            body: NSLocalizedString("ErrorBody", comment: "error"))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
    }

    func updateFriendInDB(whichFriend index: Int) {
        let documentID = friendList[index].email
        friendManager.acceptInvitation(who: documentID) { (error) in
            if error != nil {
                let errorAlert = AlertService.getErrorPopup(title: NSLocalizedString("ErrorTitle", comment: "error"),
                                                            body: NSLocalizedString("ErrorBody", comment: "error"))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
    }

    func checkInvitations(list: [Friend], completion: @escaping ([Friend]) -> Void) {
        let friendList = list
        var invitationAlert: UIAlertController?
        let index = friendList.firstIndex { (friend) -> Bool in
            friend.invitationStatus == InvitationStatus.checking
        }

        if let index = index {
            invitationAlert = AlertService.getYesNoPopup(title: NSLocalizedString("InvitationTitle", comment: "Friend invitation"),
                                                         body: NSLocalizedString("InvitationBody", comment: "Friend invitation")
                                                            + friendList[index].email,
                                                         completionYes: {
                                                            self.updateFriendInDB(whichFriend: index)
            }, completionNo: {
                self.deleteFriendFromDB(whichFriend: index)
            })
        }

        if let invitationAlert = invitationAlert {
            self.present(invitationAlert, animated: true, completion: nil)
        }
        completion(friendList)
    }

   // MARK: - Listeners
    func startListeningForFriends() {
        friendManager.getFriendsListener { friendList, error in
            if error != nil {
                let errorAlert = AlertService.getErrorPopup(title: NSLocalizedString("ErrorTitle", comment: "error"),
                                                            body: NSLocalizedString("ErrorBody", comment: "Error"))
                self.present(errorAlert, animated: true, completion: nil)
            } else {
                self.checkInvitations(list: friendList) { friends in
                    self.friendList = friends
                    self.myFriendListTableView.reloadData()
                }
            }
        }
    }

    func stopListeningForFriends() {
        friendManager.removeFriendsListener()
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
