//
//  ReadingsTest.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 8/17/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import XCTest

@testable import AsthmaHelper

class ReadingsTest: XCTestCase {

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
    }
    
    func testFEVreadingsListCount() {
        let FEV = Readings(healthType: Readings.FEVhealthType)
        XCTAssertEqual(0, FEV.list.count, "there is 0 FEV reading when start")
        let expectation = expectationWithDescription("wait for async")
        let completeClousure = {
            print("the count is \(FEV.list.count)")
            expectation.fulfill()
        }
        FEV.getReadings(completeClousure)
        waitForExpectationsWithTimeout(5, handler: {error in
            XCTAssertTrue(FEV.list.count > 0)
        })
    }
    
    // test if the count of data increase by one after create
    func testCreate() {
        let FEV = Readings(healthType: Readings.FEVhealthType)
        var initialListCount = 0
        let expectation = expectationWithDescription("wait for async")
        let completeClousure = {
            initialListCount = FEV.list.count
            expectation.fulfill()
        }
        FEV.getReadings(completeClousure)
        waitForExpectationsWithTimeout(5, handler: {error in })
        let expectation2 = expectationWithDescription("wait for async")
        let successClousure = {
            expectation2.fulfill()
        }
        let reading = Reading.init(date: NSDate(), location: "", reading: 2.1, id: NSUUID.init())
        FEV.createReading(reading, successHandler: successClousure, failHandler: {(error: NSError?) -> Void in })
        waitForExpectationsWithTimeout(5, handler: {error in
            XCTAssertEqual(initialListCount + 1, FEV.list.count)
            let last = FEV.list.last!
            XCTAssertTrue(last.date == reading.date && last.location == reading.location && last.reading == reading.reading)
        })
    }
    
    // test after deletion, the count decrease by one and the delted one is gone
    func testDelete() {
        let FEV = Readings(healthType: Readings.FEVhealthType)
        var initialListCount = 0
        var deleteFEVuuid = NSUUID.init()
        let expectation = expectationWithDescription("wait for async")
        let completeClousure = {
            initialListCount = FEV.list.count
            deleteFEVuuid = FEV.list.first!.id
            expectation.fulfill()
        }
        FEV.getReadings(completeClousure)
        waitForExpectationsWithTimeout(5, handler: {error in})
        let expectation2 = expectationWithDescription("wait for async")
        let successClousure = {expectation2.fulfill()}
        FEV.deleteReading(deleteFEVuuid, successHandler: successClousure, failHandler: {(error: NSError?) -> Void in })
        waitForExpectationsWithTimeout(5, handler: { error in
            XCTAssertEqual(initialListCount - 1, FEV.list.count)
            XCTAssertNil(FEV.list.indexOf({$0.id.isEqual(deleteFEVuuid)}))
        })
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
