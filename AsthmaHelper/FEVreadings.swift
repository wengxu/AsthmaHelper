//
//  FEVreadings.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 8/11/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import Foundation

class FEVreadings: NSObject {
    var reading = [Reading]()
    var prop1 = 1
    static var list = [Reading]()
    class func getOne() -> Int {
        return 1
    }
    func getTwo() -> Int {
        return 2
    }
}