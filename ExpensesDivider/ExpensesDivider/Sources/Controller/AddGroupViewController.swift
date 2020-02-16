//
//  AddGroupViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 17/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class AddGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var addedMembersTableView: UITableView!
    let groupManager = GroupManager()
    let userManager = UserManager()
    var friendList: [Friend] = []
    var memberList: [GroupMember] = []
    var existingGroups: [Group] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        addedMembersTableView.delegate = self
        addedMembersTableView.dataSource = self
        getExistingGroups()
    }

    @IBAction func addNewMembersTapped(_ sender: Any) {
        let newGroupMembersVC = UIStoryboard(name: Constants.Storyboard.homeStoryboard, bundle: nil)
            .instantiateViewController(withIdentifier: Constants.Storyboard.AddNewGroupMemberVC) as? AddNewGroupMemberViewController
        newGroupMembersVC?.delegate = self
        newGroupMembersVC?.alreadyAddedFriends = friendList
        self.present(UINavigationController(rootViewController: newGroupMembersVC!), animated: true, completion: nil)
    }

    @IBAction func saveNewGroupTapped(_ sender: Any) {
        let error = validateField()

        if let message = error {
            Utilities.showError(message, errorLabel)
        } else {
            let groupName = groupNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            getGroupMembers()
            let accessList = AccessControlList(members: friendList, admin: userManager.loggedUserID)
            let newGroup = Group(groupName: groupName!, groupMembers: memberList, accessControlList: accessList!)

            groupManager.addGroup(newGroup: newGroup!) { (error) in
                if error != nil {
                    Utilities.showError(NSLocalizedString("groupSavingDataError", comment: "Error during saving new group data"), self.errorLabel)
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    func validateField() -> String? {
        //check all field are full in
        let trimmedName = groupNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName == "" || friendList.isEmpty {
            return NSLocalizedString("emptyFieldsError", comment: "Empty fields error")
        }

        for group in existingGroups where group.groupName == trimmedName {
            return NSLocalizedString("sameNameofGroups", comment: "Same groups' name")
        }
        return nil
    }

    private func getGroupMembers() {
        for index in 0..<friendList.count {
            memberList.append(GroupMember(username: friendList[index].username, email: friendList[index].email, debt: Decimal(0))!)
        }
        memberList.append(GroupMember(username: userManager.loggedUserUsername, email: userManager.loggedUserEmail, debt: Decimal(0))!)
    }

    private func getExistingGroups() {
        groupManager.getGroups { (existingGroups, error) in
            if error == nil {
                self.existingGroups = existingGroups
            }
        }
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberItem", for: indexPath)
        cell.textLabel?.text = friendList[indexPath.row].username
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            friendList.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}

extension AddGroupViewController: AddMembersDelegate {
    func addMembers(members: [Friend]) {
        self.dismiss(animated: true) {
            self.friendList.append(contentsOf: members)
            self.addedMembersTableView.reloadData()
        }
    }
}
