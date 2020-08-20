//
//  Utilities.swift
//  Discipline
//
//  Created by Neo Yi Siang on 5/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    static func alertMessage(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default)
        alert.addAction(alertAction)
        return alert
    }
}
