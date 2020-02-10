//
//  FriendManager.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 01/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class FriendManager: NSObject {

    var friendListener: ListenerRegistration?
    let database = Firestore.firestore()
    let friendsRef = Firestore.firestore()
        .collection(DbConstants.users)
        .document(Auth.auth().currentUser!.uid)
        .collection(DbConstants.friends)
    let usersRef = Firestore.firestore()
        .collection(DbConstants.users)

    // MARK: - CRUD Friend
    func addFriend(newFriend: Friend, completion: @escaping (Error?) -> Void) {
        var friend = newFriend
        // Checking whether added friend exists in DB, if yes then linking UUID to friend object
        usersRef.whereField(DbConstants.emailField, isEqualTo: newFriend.email).getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("Error during checking existens of user: \(error)")
                completion(error)
                return
            }
            for doc in querySnapshot!.documents {
                // swiftlint:disable force_cast
                friend.UUID = doc.data()["uid"] as! String
                // swiftlint:enable force_cast
            }

            if let loggedUser = Auth.auth().currentUser {
                self.usersRef.document(loggedUser.uid).getDocument { (document, error) in
                    if let error = error {
                        NSLog("Error during getting user information: \(error)")
                    } else {
                        var currentUserAsFriend = Friend(uuid: document?.data()!["uid"] as? String ?? loggedUser.uid,
                                                         username: document?.data()!["username"] as? String ?? "",
                                                         email: document?.data()!["email"] as? String ?? loggedUser.email!,
                                                         debt: Decimal(0),
                                                         isAccepted: true)!
                        do {
                            try self.friendsRef.document(friend.email).setData(from: friend)
                            if friend.UUID != "" {
                                currentUserAsFriend.isAccepted = false
                                try self.usersRef.document(friend.UUID)
                                    .collection(DbConstants.friends)
                                    .document(currentUserAsFriend.email)
                                    .setData(from: currentUserAsFriend)
                            }
                            NSLog("Succesfuly added friend to the list - \(friend.email)")
                        } catch let error {
                            NSLog("New friend saving data error \(error)")
                            completion(error)
                        }
                    }
                }
            }
            completion(nil)
        }
    }

    func getFriendsListener(completion: @escaping ([Friend], Error?) -> Void) {
        var friendList = [Friend]()
        friendListener = friendsRef.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                NSLog("Error getting friend list from listener: \(error)")
                completion(friendList, error)
                return
            } else {
                friendList = []
                for document in querySnapshot!.documents {
                    friendList.append(Friend(data: document.data())!)
                }
            }
            completion(friendList, nil)
        }
        NSLog("Succesfuly establish listener to friends list")
    }

    func removeFriendsListener() {
        friendListener?.remove()
        friendListener = nil
    }

    func getFriends(completion: @escaping ([Friend], Error?) -> Void) {
        var friendsList: [Friend] = []
        friendsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("Error getting friend list: \(error)")
                completion(friendsList, error)
            } else {
                for doc in querySnapshot!.documents {
                    friendsList.append(Friend(data: doc.data())!)
                }
            }
            completion(friendsList, nil)
        }
        NSLog("Succesfuly get all friends list")
    }

    func deleteFriend(who friendID: String, completion: @escaping(Error?) -> Void) {
        friendsRef.document(friendID).delete { (error) in
            if let error = error {
                NSLog("Error deleting friend from the list: \(error)")
                completion(error)
            }
        }
        NSLog("Succesfuly delete friend from the list - \(friendID)")
        completion(nil)
    }

    func activateFriend(who friendID: String, completion: @escaping(Error?) -> Void) {
        friendsRef.document(friendID).updateData([DbConstants.isAcceptedField: true]) { (error) in
            if let error = error {
                NSLog("Error during activation of the friend: \(error)")
                completion(error)
            }
        }
        NSLog("Succesfuly activate friend from the list - \(friendID)")
        completion(nil)
    }
}
