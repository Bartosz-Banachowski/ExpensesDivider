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
    let database = Firestore.firestore()
    var friendsRef: CollectionReference!
    var friendList: [Friend] = []
    var friendListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        friendsRef = Firestore.firestore().collection("users").document((Auth.auth().currentUser?.uid)!).collection("friends")
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
        database.collection("users").document((Auth.auth().currentUser?.uid)!).collection("friends").document(documentID).delete()
        NSLog("Succesfuly delete friend from the list - \(documentID)")
    }

   // MARK: - Listeners
    func startListeningForFriends() {
        friendListener = friendsRef.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                NSLog("Error getting friend list: \(error)")
            } else {
                self.friendList = []
                for document in querySnapshot!.documents {
                    self.friendList.append(Friend(data: document.data())!)
                }
            }
            self.myFriendListTableView.reloadData()
        }
    }

    func stopListeningForFriends() {
        friendListener?.remove()
        friendListener = nil
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
