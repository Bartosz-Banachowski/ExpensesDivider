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
    let groupManager = GroupManager()
    var groupList: [Group] = []

    override func viewDidLoad() {
        super.viewDidLoad()
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
                groupVC?.groupInfo = groupList[index.row]
            }
        }
    }

    func startListeningForGroup() {
        groupManager.getGroupsListener { (groupList, error) in
            if error != nil {
                let errorAlert = AlertService.getErrorPopup(title: NSLocalizedString("ErrorTitle", comment: "error"),
                                                            body: NSLocalizedString("ErrorBody", comment: "Error"))
                self.present(errorAlert, animated: true, completion: nil)
            } else {
                self.groupList = groupList
                self.groupListTableView.reloadData()
            }
        }
    }

    func stopListeningForGroup() {
        groupManager.removeGroupsListener()
    }

    func deleteGroupFromDB(whichGroup index: Int) {
        if let documentID = groupList[index].UUID {
            groupManager.deleteGroup(which: documentID) { (error) in
                if error != nil {
                    let errorAlert = AlertService.getErrorPopup(title: NSLocalizedString("ErrorTitle", comment: "error"),
                                                                body: NSLocalizedString("ErrorBody", comment: "error"))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        }
        let errorAlert = AlertService.getErrorPopup(title: NSLocalizedString("ErrorTitle", comment: "error"),
                                                    body: NSLocalizedString("ErrorBody", comment: "error"))
        self.present(errorAlert, animated: true, completion: nil)
    }

    // MARK: - Group Table View data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupListItem", for: indexPath) as! GroupCell
        // swiftlint:enable force_cast

        let group = groupList[indexPath.row]
        cell.setGroup(group: group)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteGroupFromDB(whichGroup: indexPath.row)
            groupList.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}
