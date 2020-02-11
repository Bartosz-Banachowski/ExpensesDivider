//
//  GroupManager.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 06/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class GroupManager: NSObject {

    let groupsRef = Firestore.firestore()
        .collection(DbConstants.groups)
    let userManager = UserManager()
    var groupListener: ListenerRegistration?

    // MARK: - CRUD Group
    func addGroup(newGroup: Group, completion: @escaping(Error?) -> Void) {
        do {
            let document = try groupsRef.addDocument(from: newGroup)
            groupsRef.document(document.documentID).updateData(["UUID": document.documentID])
        } catch let error {
            NSLog("Error adding new group to the databse: \(error)")
            completion(error)
        }
        NSLog("Succesfuly added new group to group list")
        completion(nil)
    }

    func getGroupsListener(completion: @escaping ([Group], Error?) -> Void) {
        var groupList = [Group]()
        groupListener = groupsRef
            .whereField(DbConstants.accessControlList + "." + userManager.loggedUserID, in: [DbConstants.admin, DbConstants.member])
            .addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                NSLog("Error getting group list listener: \(error)")
                completion(groupList, error)
                return
            } else {
                groupList = []
                for document in querySnapshot!.documents {
                    groupList.append(Group(data: document.data())!)
                }
            }
            completion(groupList, nil)
        }
        NSLog("Succesfuly establish listener to group list")
    }

    func removeGroupsListener() {
        groupListener?.remove()
        groupListener = nil
        NSLog("Succesfuly remove listener to group list")
    }

    func getGroups(completion: @escaping ([Group], Error?) -> Void) {
        groupsRef
            .whereField(DbConstants.accessControlList + "." + userManager.loggedUserID, in: [DbConstants.admin, DbConstants.member])
            .getDocuments { (querySnapshot, error) in
            var existingGroups = [Group]()
            if let error = error {
                NSLog("Error getting group list: \(error)")
                completion(existingGroups, error)
                return
            } else {
                existingGroups = []
                for document in querySnapshot!.documents {
                    existingGroups.append(Group(data: document.data())!)
                }
            }
            NSLog("Succesfuly got group list")
            completion(existingGroups, nil)
        }
    }

    func deleteGroup(which groupID: String, completion: @escaping(Error?) -> Void) {
        groupsRef.document(groupID).delete { (error) in
            if let error = error {
                NSLog("Error deleting group from the list: \(error)")
                completion(error)
            }
        }
        NSLog("Succesfuly delete group from the list - \(groupID)")
        completion(nil)
    }
}
