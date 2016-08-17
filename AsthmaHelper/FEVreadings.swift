//
//  FEVreadings.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 8/11/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

// can use anchor query to improve efficiency 
// can use HKstatistics options to ask for query ahead of time

import Foundation
import HealthKit

class FEVreadings: Readings {
    init() {
        super.init(healthType: Readings.FEVhealthType)
    }
    
    
}