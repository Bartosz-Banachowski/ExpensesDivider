//
//  AlertService.swift
//  ExpensesDivider
//
//  Created by Bartosz Banachowski on 05/02/2020.
//  Copyright © 2020 Banachowski Bartosz. All rights reserved.
//

import UIKit

class AlertService {

    static func getYesNoPopup(title: String, body: String, completionYes: @escaping () -> Void, completionNo: @escaping () -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            completionYes()
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
            completionNo()
            alert.dismiss(animated: true, completion: nil)
        }))

        return alert
    }
}
