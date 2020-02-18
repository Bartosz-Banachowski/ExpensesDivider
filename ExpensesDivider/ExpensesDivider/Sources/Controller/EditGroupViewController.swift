//
//  EditGroupViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 17/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class EditGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var groupMemberTableView: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    let groupManager = GroupManager()
    let userManager = UserManager()
    var existingGroups: [Group] = []
    var groupInfo: Group!
    var friendList: [Friend] = []
    var memberList: [GroupMember] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setupView()
        groupMemberTableView.delegate = self
        groupMemberTableView.dataSource = self
    }

    func setupView() {
        conversionToFriend(members: groupInfo.groupMembers)
        nameTextField.text = groupInfo.groupName
        groupMemberTableView.reloadData()
    }

    func conversionToFriend(members: [GroupMember]) {
        for member in members {
            friendList.append(Friend(uuid: "", username: member.username, email: member.email, invitationStatus: .accepted)!)
        }
    }

    @IBAction func updateGroupTapped(_ sender: Any) {
        let error = validateField()

        if let message = error {
            Utilities.showError(message, errorLabel)
        } else {
            let groupName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            conversionToGroupMember()
            let accessList = AccessControlList(members: friendList, admin: userManager.loggedUserID)
            groupInfo.groupName = groupName!
            groupInfo.accessControlList = accessList!.accessControlList
            groupInfo.groupMembers = memberList

            groupManager.editGroup(group: groupInfo) { (error) in
                if error != nil {
                    Utilities.showError(NSLocalizedString("groupSavingDataError", comment: "Error during saving new group data"), self.errorLabel)
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func addPeopleToGroupTapped(_ sender: Any) {
        let newGroupMembersVC = UIStoryboard(name: Constants.Storyboard.homeStoryboard, bundle: nil)
            .instantiateViewController(withIdentifier: Constants.Storyboard.AddNewGroupMemberVC) as? AddNewGroupMemberViewController
        newGroupMembersVC?.delegate = self
        newGroupMembersVC?.alreadyAddedFriends = friendList
        self.present(UINavigationController(rootViewController: newGroupMembersVC!), animated: true, completion: nil)
    }

    private func conversionToGroupMember() {
        for index in 0..<friendList.count {
            memberList.append(GroupMember(username: friendList[index].username, email: friendList[index].email, debt: Decimal(0))!)
        }
        if !memberList.contains(where: { (member) -> Bool in
            member.email == userManager.loggedUserEmail
        }) {
            memberList.append(GroupMember(username: userManager.loggedUserUsername, email: userManager.loggedUserEmail, debt: Decimal(0))!)
        }
    }

    func validateField() -> String? {
        //check all field are full in
        let trimmedName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName == "" || friendList.isEmpty {
            return NSLocalizedString("emptyFieldsError", comment: "Empty fields error")
        }

        for group in existingGroups where group.groupName == trimmedName {
            return NSLocalizedString("sameNameofGroups", comment: "Same groups' name")
        }
        return nil
    }

    private func getExistingGroups() {
        groupManager.getGroups { (existingGroups, error) in
            if error == nil {
                self.existingGroups = existingGroups
            }
        }
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberEditItem", for: indexPath)
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

extension EditGroupViewController: AddMembersDelegate {
    func addMembers(members: [Friend]) {
        self.dismiss(animated: true) {
            self.friendList.append(contentsOf: members)
            self.groupMemberTableView.reloadData()
        }
    }
}
