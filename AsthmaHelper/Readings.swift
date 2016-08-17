//
//  Readings.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 8/14/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import Foundation
import HealthKit

class Readings : NSObject {
    static let healthStore = HKHealthStore()
    static let FVChealthType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierForcedVitalCapacity)!
    static let FEVhealthType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierForcedExpiratoryVolume1)!
    init(healthType: HKSampleType) {
        self.healthType = healthType
    }
    
    var healthType: HKSampleType
    
    
    // use anchor to anchor on FEV data(know which data is already queried)
    var queryAnchor = HKQueryAnchor.init(fromValue: 0)
    var list = [Reading]()
    
    static func removeFromList() {
        
    }
    
    func getReadings(completeClousure: () -> Void) {
        let query = HKAnchoredObjectQuery(type: healthType, predicate: nil, anchor: queryAnchor, limit: 500, resultsHandler: {(query, newSamples,                                               deletedSamples, newAnchor, error) -> Void in
            guard let samples = newSamples as? [HKQuantitySample], let deleted = deletedSamples else {
                print("*** Unable to query for FEV data: \(error?.localizedDescription)")
                abort()
            }
            // process the results
            self.queryAnchor = newAnchor!
            
            for s in samples {
                let location = ((s.metadata?["location"]) != nil) ? s.metadata?["location"] as? String : ""
                let reading = s.quantity.doubleValueForUnit(HKUnit.literUnit())
                self.list.append(Reading(date: s.startDate, location: location!, reading: reading, id: s.UUID))
            }
            
            for s in deleted {
                let removeIndex = self.list.indexOf({(element) -> Bool in element.id.isEqual(s.UUID)})
                if (removeIndex != nil) {
                    self.list.removeAtIndex(removeIndex!)
                }
            }
            completeClousure()
            }
            
        )
        Readings.healthStore.executeQuery(query)
    }
    
    func createReading(r: Reading, successHandler: () -> Void, failHandler: () -> Void) {
        let literUnit = HKUnit.literUnit()
        let quantity = HKQuantity.init(unit: literUnit, doubleValue: r.reading)
        let quantitySample = HKQuantitySample.init(type: healthType as! HKQuantityType, quantity: quantity, startDate: r.date, endDate: r.date, device: HKDevice.localDevice(), metadata: ["location": r.location])
        Readings.healthStore.saveObject(quantitySample, withCompletion: {success, error in
            if (success) {
                self.getReadings(successHandler)
            } else {
                print("error saving data: \(error)")
                failHandler()
            }
        })
    }
    
    // next step: make sure list get updated automatically without a new fetch.
    func deleteReading(id: NSUUID, successHandler: () -> Void, failHandler: () -> Void) {
        let predicate = HKQuery.predicateForObjectWithUUID(id)
        Readings.healthStore.deleteObjectsOfType(healthType, predicate: predicate, withCompletion: {success, deletedObjCount, error in
            if (success) {
                self.getReadings(successHandler)
            } else {
                print("Error deleting data: \(error)")
                failHandler()
            }
        })
    }
    
    
}