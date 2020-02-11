//
//  BillManager.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 11/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase

class BillManager: NSObject {

    let billsRef: CollectionReference
    let userManager = UserManager()
    var billListener: ListenerRegistration?
    var detailedBillListener: ListenerRegistration?

    init(UUID: String) {
        billsRef = Firestore.firestore()
            .collection(DbConstants.groups).document(UUID).collection(DbConstants.bills)
    }

    func getBillListener(completion: @escaping ([Bill], Error?) -> Void) {
        var billList = [Bill]()
        billListener = billsRef.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                NSLog("Error getting bills list: \(error)")
                completion(billList, error)
                return
            } else {
                billList = []
                for document in querySnapshot!.documents {
                    billList.append(Bill(data: document.data())!)
                }
            }
            completion(billList, nil)
        }
        NSLog("Succesfuly establish listener to bill list")
    }

    func removeBillListener() {
        billListener?.remove()
        billListener = nil
    }

    func getDetailedBillListener(UUID: String, completion: @escaping (Bill?, Error?) -> Void) {
        var bill: Bill?
        detailedBillListener = billsRef.document(UUID).addSnapshotListener { (docSnapshot, error) in
            if let error = error {
                NSLog("Error getting detailed bill info: \(error)")
                completion(nil, error)
                return
            } else {
                if let data = docSnapshot?.data() {
                    bill = Bill(data: data)
                }
            }
            completion(bill, nil)
        }
        NSLog("Succesfuly establish listener to detailed bill list")
    }

    func removeDetailedBillListener() {
        billListener?.remove()
        billListener = nil
    }

    func getBills(completion: @escaping ([Bill], Error?) -> Void) {
        var existingBills = [Bill]()
        billsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                NSLog("Error getting bill list: \(error)")
                completion(existingBills, error)
                return
            } else {
                existingBills = []
                for document in querySnapshot!.documents {
                    existingBills.append(Bill(data: document.data())!)
                }
            }
            NSLog("Succesfuly got bill list")
            completion(existingBills, nil)
        }
    }

    func addBill(newBill: Bill, completion: @escaping(Error?) -> Void) {
        do {
            try billsRef.document(newBill.description).setData(from: newBill)
        } catch let error {
            NSLog("Error adding new bill to the database: \(error)")
            completion(error)
        }
        NSLog("Succesfuly added new bill to group list")
        completion(nil)
    }

    func updateBill(which bill: Bill, completion: @escaping(Error?) -> Void) {
        do {
            try billsRef.document(bill.description).setData(from: bill)
        } catch let error {
            NSLog("Error updating the bill to the database: \(error)")
            completion(error)
        }
        NSLog("Succesfuly updated the bill")
        completion(nil)
    }

    func deleteBill(which billID: String, completion: @escaping(Error?) -> Void) {
        billsRef.document(billID).delete { (error) in
            if let error = error {
                NSLog("Error deleting bill from the list: \(error)")
                completion(error)
            }
        }
        NSLog("Succesfuly delete bill from the list - \(billID)")
        completion(nil)
    }
}
