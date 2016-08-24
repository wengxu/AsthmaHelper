//
//  TrendViewControllerTest.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 8/19/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import XCTest

@testable import AsthmaHelper

class TrendViewControllerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
       
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testNoFEVDataLabel() {
        let expectedText = "No FEV data"
        XCUIApplication().tabBars.buttons["Trend"].tap()
        let cells = XCUIApplication().tables.cells
        let topCell = cells.elementBoundByIndex(0)
        /*
         let children = topCell.childrenMatchingType(XCUIElementType.Any)
         let child0 = children.elementBoundByIndex(0)
         let text = child0.label
         */
        let labelElement = topCell.staticTexts[expectedText]
        
        let exists = NSPredicate(format: "exists == 1")
        expectationForPredicate(exists, evaluatedWithObject: labelElement, handler: nil)
        waitForExpectationsWithTimeout(5, handler: {error in
            sleep(1)
            XCTAssertEqual(expectedText, labelElement.label)
        })
    }
    
    func testNoFVCDataLabel() {
        // delete all FVC data and try to test no FVC data label
        
        let expectedText = "No FVC data"
        //let chartModel = Readings(healthType: Readings.FEVhealthType)
        /*
        
        let expectation = expectationWithDescription("wait for async")
        
        chartModel.getReadings({
            for r in chartModel.list {
                chartModel.deleteReading(r.id, successHandler: {expectation.fulfill()}, failHandler: {XCTAssertTrue(0 == 1)})
                self.waitForExpectationsWithTimeout(5, handler: {error in })
            }
        })
        XCUIApplication().tabBars.buttons["Trend"].tap()
        let cells = XCUIApplication().tables.cells
        let topCell = cells.elementBoundByIndex(0)
        let labelElement = topCell.staticTexts[expectedText]
        let exists = NSPredicate(format: "exists == 1")
        expectationForPredicate(exists, evaluatedWithObject: labelElement, handler: nil)
        waitForExpectationsWithTimeout(5, handler: {error in
            sleep(1)
            XCTAssertEqual(expectedText, labelElement.label)
        })
        */
        
    }
    
    func test() {
        /*
        let app = XCUIApplication()
        app.tabBars.buttons["FVC Data Reading"].tap()
        
        let fvcDataReadingNavigationBar = app.navigationBars["FVC Data Reading"]
        fvcDataReadingNavigationBar.buttons["Edit"].tap()
        fvcDataReadingNavigationBar.buttons["Done"].tap()
        // -----
        
        let app = XCUIApplication()
        app.scrollViews.otherElements.containingType(.Icon, identifier:"Game Center").childrenMatchingType(.Icon).matchingIdentifier("AsthmaHelper").elementBoundByIndex(0).tap()
        
        let tabBarsQuery = app.tabBars
        let fevDataReadingButton = tabBarsQuery.buttons["FEV Data Reading"]
        fevDataReadingButton.tap()
        tabBarsQuery.buttons["FVC Data Reading"].tap()
        
        let fvcDataReadingNavigationBar = app.navigationBars["FVC Data Reading"]
        fvcDataReadingNavigationBar.buttons["Edit"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.buttons["Delete Jun 24, 2016 12:08 AM, 1.0 L"].tap()
        tablesQuery.buttons["Delete"].tap()
        
        let deleteDataAlert = app.alerts["Delete Data"]
        let okButton = deleteDataAlert.collectionViews.buttons["OK"]
        okButton.tap()
        app.otherElements.containingType(.Alert, identifier:"Delete Data").element.tap()
        deleteDataAlert.tap()
        okButton.tap()
        fvcDataReadingNavigationBar.buttons["Done"].tap()
        fevDataReadingButton.tap()
        tabBarsQuery.buttons["My Info"].tap()
        fevDataReadingButton.tap()
        tabBarsQuery.buttons["Trend"].tap()
        
        let helloStaticText = tablesQuery.staticTexts["Hello"]
        helloStaticText.tap()
        helloStaticText.tap()
        helloStaticText.tap()
        */
    }

}
