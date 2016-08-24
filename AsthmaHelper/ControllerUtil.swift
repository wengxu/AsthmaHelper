//
//  ControllerUtil.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 8/18/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import Foundation
import UIKit

class ControllerUtil: NSObject {
    static func displayAlert(controller: UIViewController,title: String, msg: String) -> Void {
        let alert = UIAlertController.init(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        controller.presentViewController(alert, animated: true, completion: nil)
    }
}