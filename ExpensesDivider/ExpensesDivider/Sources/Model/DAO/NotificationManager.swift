//
//  NotificationManager.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 17/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

class NotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {

    let database = Firestore.firestore()
    let notificationTokensRef = Firestore.firestore()
        .collection(DbConstants.notificationTokens)
    let userManager = UserManager()

    func getDeviceTokensForDebtor(debtor: String, completion: @escaping ([NotificationToken], Error?) -> Void) {
        var notificationTokenList = [NotificationToken]()
        notificationTokensRef
            .whereField(DbConstants.UUIDField, isEqualTo: debtor)
            .whereField(DbConstants.deviceTokenField, isGreaterThan: "")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    NSLog("Error getting tokens notifications : \(error)")
                    completion(notificationTokenList, error)
                    return
                } else {
                    notificationTokenList = []
                    for document in querySnapshot!.documents {
                        notificationTokenList.append(NotificationToken(data: document.data())!)
                    }
                }
                completion(notificationTokenList, nil)
        }
        NSLog("Succesfuly got notification tokens list")
    }

    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            // APNS notification for iOS version 10.0+
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })

            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
        updateFirestoreDeviceToken()
    }

    func updateFirestoreDeviceToken() {
        if let deviceToken = Messaging.messaging().fcmToken {
            let userToken = NotificationToken(UUID: userManager.loggedUserEmail, deviceToken: deviceToken)
            do {
                try database
                    .collection(DbConstants.notificationTokens)
                    .document(userManager.loggedUserID)
                    .setData(from: userToken)
            } catch let error {
                NSLog("Update firestore Device token error \(error)")
            }
        }
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        updateFirestoreDeviceToken()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
    }
}
