//
//  FEVReading.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 5/25/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import UIKit

class Reading: NSObject {
    var date: NSDate
    var location: String
    var reading: Double
    var abc: Int
    
    override var description: String {return " ** Reading: \(String(reading)) and Date: \(String(date)) ** "}
    
    init(date: NSDate, location: String, reading: Double ) {
        self.date = date
        self.location = location
        self.reading = reading
        self.abc = 1
    }
    
    func getDateAndTimeStr() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "MMM dd, yyyy h:mm a"
        return df.stringFromDate(self.date)
    }
    
    func getDateStr() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        return df.stringFromDate(self.date)
    }
    
    func getTimeStr() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "h:mm a"
        return df.stringFromDate(self.date)
    }
    
    func desc() -> String {
        return "** Reading: \(String(reading)) and Date: \(String(date)) **"
    }
    
    func getOne() -> Int {
        return 1
    }
    
    class func getTwo() -> Int {
        return 2
    }
}
