//
//  FEVReading.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 5/25/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import UIKit

class Reading: NSObject {
    var id: NSUUID
    var date: NSDate
    var location: String
    var reading: Double
    
    override var description: String {return " ** Reading: \(String(reading)) and Date: \(String(date)) ** "}
    
    init(date: NSDate, location: String, reading: Double, id: NSUUID) {
        self.date = date
        self.location = location
        self.reading = reading
        self.id = id
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
}
