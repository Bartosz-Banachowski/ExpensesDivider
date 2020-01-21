//
//  GroupListViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 14/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class GroupListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var groupListTableView: UITableView!
    let database = Firestore.firestore()
    var groupsRef: CollectionReference!
    var groupsList: [Group] = []
    var groupListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        groupsRef = Firestore.firestore().collection("users").document((Auth.auth().currentUser?.uid)!).collection("groups")
        groupListTableView.delegate = self
        groupListTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        startListeningForGroup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopListeningForGroup()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is GroupViewController {
            let groupVC = segue.destination as? GroupViewController
            if let index = self.groupListTableView.indexPathForSelectedRow {
                groupVC?.groupInfo = groupsList[index.row]
            }
        }
    }

    func startListeningForGroup() {
        groupListener = groupsRef.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                NSLog("Error getting group list: \(error)")
            } else {
                self.groupsList = []
                for document in querySnapshot!.documents {
                    self.groupsList.append(Group(data: document.data())!)
                }
            }
            self.groupListTableView.reloadData()
        }
    }

    func stopListeningForGroup() {
        groupListener?.remove()
        groupListener = nil
    }

    func deleteGroupFromDB(whichGroup index: Int) {
        let documentID = groupsList[index].groupName
        database.collection("users").document((Auth.auth().currentUser?.uid)!).collection("groups").document(documentID).delete()
        NSLog("Succesfuly delete group from the list - \(documentID)")
    }

    // MARK: - Group Table View data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupListItem", for: indexPath) as! GroupCell
        // swiftlint:enable force_cast

        let group = groupsList[indexPath.row]
        cell.setGroup(group: group)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteGroupFromDB(whichGroup: indexPath.row)
            groupsList.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}
