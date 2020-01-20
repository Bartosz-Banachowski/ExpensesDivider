//
//  GroupViewController.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 17/01/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class GroupViewController: UIViewController {

    let database = Firestore.firestore()
    var groupInfo: Group!
    var groupName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        getGroupInfo()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddBillViewController {
            let billVC = segue.destination as? AddBillViewController
            billVC?.groupInfo = self.groupInfo
        }
    }

    func getGroupInfo() {
        database.collection("users")
            .document((Auth.auth().currentUser?.uid)!)
            .collection("groups")
            .document(groupName)
            .getDocument { (documentSnapshot, error) in
            if let error = error {
                NSLog("Error getting group member list: \(error)")
            } else {
                if let document = documentSnapshot?.data() {
                    self.groupInfo = Group(data: document)
                }
            }
        }
    }
}
