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
    let database = Firestore.firestore()
    var groupRef: CollectionReference!
    var memberList: [Friend] = []
    var existingGroups: [Group] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        groupRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("groups")
        addedMembersTableView.delegate = self
        addedMembersTableView.dataSource = self
        getDocuments()
    }

    @IBAction func addNewMembersTapped(_ sender: Any) {
        let newGroupMembersVC = UIStoryboard(name: "Home", bundle: nil)
            .instantiateViewController(withIdentifier: "AddNewGroupMemberVC") as? AddNewGroupMemberViewController
        newGroupMembersVC?.delegate = self
        self.present(UINavigationController(rootViewController: newGroupMembersVC!), animated: true, completion: nil)
    }

    @IBAction func saveNewGroupTapped(_ sender: Any) {
        let error = validateField()

        if let message = error {
            Utilities.showError(message, errorLabel)
        } else {
            let groupName = groupNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let newGroup = Group(groupName: groupName!, groupMembers: memberList)

            do {
                try groupRef.document(newGroup!.groupName).setData(from: newGroup)
            } catch let error {
                Utilities.showError(NSLocalizedString("groupSavingDataError", comment: "Error during saving new group data"), self.errorLabel)
                NSLog("New group saving data error \(error)")
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    func validateField() -> String? {
        //check all field are full in
        let trimmedName = groupNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName == "" {
            return NSLocalizedString("emptyFieldsError", comment: "Empty fields error")
        }

        for group in existingGroups where group.groupName == trimmedName {
            return NSLocalizedString("sameNameofGroups", comment: "Same groups' name")
        }
        return nil
    }

    private func getDocuments() {
        groupRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("Error getting group list: \(error)")
            } else {
                self.existingGroups = []
                for document in querySnapshot!.documents {
                    self.existingGroups.append(Group(data: document.data())!)
                }
            }
        }
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberItem", for: indexPath)
        cell.textLabel?.text = memberList[indexPath.row].username
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            memberList.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}

extension AddGroupViewController: AddMembersDelegate {
    func addMembers(members: [Friend]) {
        self.dismiss(animated: true) {
            self.memberList.append(contentsOf: members)
            self.addedMembersTableView.reloadData()
        }
    }
}
