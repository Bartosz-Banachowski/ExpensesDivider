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
    let userManager = UserManager()
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
            groupVC?.userManager = userManager
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
        } else {
            let errorAlert = AlertService.getErrorPopup(title: NSLocalizedString("ErrorTitle", comment: "error"),
                                                        body: NSLocalizedString("ErrorBody", comment: "error"))
            self.present(errorAlert, animated: true, completion: nil)
        }
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
        cell.setGroup(group: group, user: userManager.loggedUserID)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            if groupList[indexPath.row].accessControlList[userManager.loggedUserID] == AccessLevel.admin {
//                deleteGroupFromDB(whichGroup: indexPath.row)
//                groupList.remove(at: indexPath.row)
//                tableView.beginUpdates()
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//                tableView.endUpdates()
//            } else {
//                let accessErrorAlert = AlertService.getErrorPopup(title: NSLocalizedString("AccessErrorTitle", comment: "AccessError"),
//                                                                  body: NSLocalizedString("AccessErrorBody", comment: "AccessError"))
//                self.present(accessErrorAlert, animated: true, completion: nil)
//            }
//        }
//    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            if self.groupList[indexPath.row].accessControlList[self.userManager.loggedUserID] == AccessLevel.admin {
                self.deleteGroupFromDB(whichGroup: indexPath.row)
                self.groupList.remove(at: indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            } else {
                let accessErrorAlert = AlertService.getErrorPopup(title: NSLocalizedString("AccessErrorTitle", comment: "AccessError"),
                                                                  body: NSLocalizedString("AccessErrorBody", comment: "AccessError"))
                self.present(accessErrorAlert, animated: true, completion: nil)
            }
        }

        let editButton = UITableViewRowAction(style: .normal, title: "Edit") { (_, indexPath) in
            if self.groupList[indexPath.row].accessControlList[self.userManager.loggedUserID] == AccessLevel.admin {
                let editGroupVC = UIStoryboard(name: Constants.Storyboard.homeStoryboard, bundle: nil)
                           .instantiateViewController(withIdentifier: Constants.Storyboard.editGroupVC) as? EditGroupViewController
                editGroupVC?.groupInfo = self.groupList[indexPath.row]
                self.present(UINavigationController(rootViewController: editGroupVC!), animated: true, completion: nil)
            } else {
                let accessErrorAlert = AlertService.getErrorPopup(title: NSLocalizedString("AccessErrorTitle", comment: "AccessError"),
                                                                  body: NSLocalizedString("AccessErrorBody", comment: "AccessError"))
                self.present(accessErrorAlert, animated: true, completion: nil)
            }
        }

        deleteButton.backgroundColor = .systemRed
        editButton.backgroundColor = .systemOrange
        return [deleteButton, editButton]
    }
}
