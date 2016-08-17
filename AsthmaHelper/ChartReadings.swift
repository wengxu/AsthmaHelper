//
//  ChartReadings.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 8/17/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import Foundation
import HealthKit

// chart readings include aggregation of FEV readings 
// and average of FVC readings
class ChartReadings : Readings {
    var FEVlist = [Reading]()
    var avgFVC : Reading
    init() {
        avgFVC = Reading.init(date: NSDate(), location: "", reading: -1, id: NSUUID.init())
        super.init(healthType: Readings.FEVhealthType)
    }
    
    func getFEVchartReadings(nDays: Int, successHandler: () -> Void, failHandler: () -> Void) {
        let calendar = NSCalendar.currentCalendar()
        let startDate = calendar.dateByAddingUnit(.Day, value: -nDays + 1, toDate: NSDate(), options: [])
        let endDate = NSDate()
        // set anchor date to be 12:00 am of today
        let anchorComponents = calendar.components([.Day, .Month, .Year], fromDate: NSDate())
        guard let anchorDate = calendar.dateFromComponents(anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        let interval = NSDateComponents()
        interval.day = 1
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        let query = HKStatisticsCollectionQuery(quantityType: Readings.FEVhealthType, quantitySamplePredicate: predicate, options: .DiscreteAverage, anchorDate: anchorDate, intervalComponents: interval)
        // set query result handler
        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else {
                failHandler()
                fatalError("*** An error occurred while calculating the FEV statistics: \(error?.localizedDescription) ***")
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.FEVlist.removeAll()
                statsCollection.enumerateStatisticsFromDate(startDate!, toDate: endDate, withBlock: {stats, stop in
                    var reading : Double = -1
                    if let quantity = stats.averageQuantity() {
                        reading = quantity.doubleValueForUnit(HKUnit.literUnit())
                    }
                    let date = stats.startDate
                    self.FEVlist.append(Reading(date: date, location: "", reading: reading, id: NSUUID.init()))
                })
                successHandler()
            }
            
        }
        Readings.healthStore.executeQuery(query)
    }
    
    func getAvgFVC(nDays: Int, successHandler: () -> Void, failHandler: () -> Void) {
        let calendar = NSCalendar.currentCalendar()
        let endDate = NSDate()
        let startDate = calendar.dateByAddingUnit(.Day, value: -nDays, toDate: endDate, options: [])
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        let query = HKStatisticsQuery(quantityType: Readings.FVChealthType, quantitySamplePredicate: predicate, options: .DiscreteAverage, completionHandler: {query, result, error in
            guard let result = result else {
                failHandler()
                fatalError("*** An error occurred while calculating the FVC statistics: \(error?.localizedDescription) ***")
            }
            dispatch_async(dispatch_get_main_queue()) {
                var reading : Double = -1
                if let quantity = result.averageQuantity() {
                    reading = quantity.doubleValueForUnit(HKUnit.literUnit())
                }
                let date = result.startDate
                self.avgFVC = Reading(date: date, location: "", reading: reading, id: NSUUID.init())
                successHandler()
            }
        })
        Readings.healthStore.executeQuery(query)
    }
}