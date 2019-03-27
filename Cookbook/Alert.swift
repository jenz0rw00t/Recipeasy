//
//  Alert.swift
//  Cookbook
//
//  Created by Jens Sellén on 2019-03-25.
//  Copyright © 2019 Jens Sellén. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    
    static func showBasicOkAlert(on vc:UIViewController, with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
    
}
