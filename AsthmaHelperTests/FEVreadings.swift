//
//  FEVreadings.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 8/11/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import XCTest

@testable import AsthmaHelper

class FEVreadings: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //XCTAssert(<#T##expression: BooleanType##BooleanType#>)
        var a = Reading.init(date: NSDate(), location: "", reading: 1)
        var b = Reading.getTwo()
        
        
        
        
        //XCTAssertEqual(FEVreadings., 1, "yes'")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
