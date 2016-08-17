//
//  ChartReadingsTest.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 8/17/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import XCTest

@testable import AsthmaHelper

class ChartReadingsTest: XCTestCase {

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
    
    func testGetFEVsXDays(nDays: Int) {
        let chartModel = ChartReadings.init()
        XCTAssertEqual(0, chartModel.FEVlist.count)
        let expectation = expectationWithDescription("wait for async")
        let successClousure = {
            print("the count is \(chartModel.FEVlist.count)")
            expectation.fulfill()
        }
        let failClousure = {
            XCTAssertTrue(0 == 1)
            expectation.fulfill()
        }
        chartModel.getFEVchartReadings(nDays, successHandler: successClousure, failHandler: failClousure)
        waitForExpectationsWithTimeout(5, handler: {error in
            XCTAssertEqual(nDays, chartModel.FEVlist.count)
        })
    }
    
    func testGetFEVs() {
        let testArray = [7, 14, 30, 60, 360]
        for nDays in testArray {
            testGetFEVsXDays(nDays)
        }
    }
    
    func testGetFVCxDays(nDays: Int) {
        let chartModel = ChartReadings.init()
        XCTAssertEqual(-1, chartModel.avgFVC)
        let expectation = expectationWithDescription("wait for async")
        let successClousure = {expectation.fulfill()}
        let failClousure = {
            XCTAssertTrue(0 == 1)
            expectation.fulfill()
        }
        chartModel.getAvgFVC(nDays, successHandler: successClousure, failHandler: failClousure)
        waitForExpectationsWithTimeout(5, handler: {error in
            XCTAssertTrue(chartModel.avgFVC.reading > 0)
            //XCTAssertEqual(2.1, chartModel.avgFVC)
        })
    }
    
    func testGetFVC() {
        let testArray = [7, 14, 30, 60, 360]
        for nDays in testArray {
            testGetFEVsXDays(nDays)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
