//
//  AuthChecker.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 8/28/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

class AuthChecker: NSObject {
    
    // healthKit
    func healthDataTypesToWrite() -> Set<HKSampleType> {
        return NSSet.init(objects: Readings.FEVhealthType, Readings.FVChealthType) as! Set<HKSampleType>
    }
    
    func healthDataTypesToRead() -> Set<HKObjectType> {
        return NSSet.init(objects: Readings.FEVhealthType, Readings.FVChealthType) as! Set<HKSampleType>
    }
    
    func askPermission(controller: UIViewController, askCompleteHandler: () -> Void) {
        // ask for Healthkit permission
        if HKHealthStore.isHealthDataAvailable() {
            let HKwriteDatatypes = healthDataTypesToWrite()
            let HKreadDatatypes = healthDataTypesToRead()
            
            Readings.healthStore.requestAuthorizationToShareTypes(HKwriteDatatypes, readTypes: HKreadDatatypes, completion: {(success , error ) -> Void in
                let generalMsg = "Some functionality may not be working properly. \n To grant data access, go to the built-in Health App -> click \"Health Data\" -> \"Results\" -> \"Forced Expiratory Volume\"/\"Forced Vital Capacity\" -> \"Share Data\" -> \"Edit\" -> Enable both Share Data and Data Source."
                if !success {
                    let msg = "Error process request. " + generalMsg
                    ControllerUtil.displayAlert(controller, title: "Data Authentication", msg: msg)
                }
                self.checkPermission("FEV", healthType: Readings.FEVhealthType, generalMsg: generalMsg, controller: controller)
                self.checkPermission("FVC", healthType: Readings.FVChealthType, generalMsg: generalMsg, controller: controller)
                askCompleteHandler()
            })
        } else {
            ControllerUtil.displayAlert(controller, title: "Error", msg: "HealthKit not available, some functionality may not be working properly.")
        }
    }
    
    // this function checks given health data type permission and
    // generate alert if data access permission denied.
    func checkPermission(typeStr: String, healthType: HKObjectType, generalMsg: String, controller: UIViewController) -> Bool {
        var result = false
        let permissionResult = Readings.healthStore.authorizationStatusForType(healthType)
        switch permissionResult {
        case HKAuthorizationStatus.SharingDenied:
            let msg = typeStr + " data authorization not (fully) granted. " + generalMsg
            ControllerUtil.displayAlert(controller, title: "Data Authentication", msg: msg)
        case HKAuthorizationStatus.SharingAuthorized:
            print(typeStr + " authorization granted")
            result = true
        default:
            let msg = "Error process request. " + generalMsg
            ControllerUtil.displayAlert(controller, title: "Data Authentication", msg: msg)
        }
        return result
    }
    
    func FEVandFVCbothAuthorized() -> Bool {
        var result = true
        let healthTypeToCheck = [Readings.FEVhealthType, Readings.FVChealthType]
        for type in healthTypeToCheck {
            if !checkAuthStatusFor(type) {
                result = false
            }
        }
        return result
    }
    
    func checkAuthStatusFor(healthType: HKSampleType) -> Bool {
        return Readings.healthStore.authorizationStatusForType(healthType) == HKAuthorizationStatus.SharingAuthorized
    }
    
}