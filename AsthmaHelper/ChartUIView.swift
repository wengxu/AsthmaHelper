//
//  ChartUIView.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 6/14/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import UIKit
import HealthKit

class ChartUIView: UIView {
    
    // average FEV reading for the last week (including today(the last one))
    var FEVdataPoints:[Reading] = [Reading]()
    
    // average FVC reading for the last 3 month
    var FVCdata:Double = -1
    
    var healthStore = HKHealthStore()
    
    let FEVhealthType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierForcedExpiratoryVolume1)!
    
    let FVChealthType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierForcedVitalCapacity)!
    
    var queryComplete:[Bool] = [false, false]
    
    var needsRefresh: Bool = true
    
    
    // draw central text
    let centralText = UILabel.init(frame: CGRectMake(300 * 0.2, 250 * 0.2, 300 * 0.6, 250 * 0.6))
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        queryFEVAndUpdate()
        queryFVCAndUpdate()
        
        print("the FEV data using stats query is \(FEVdataPoints) ")
        print(" the FVC data using stat query is \(FVCdata)")
        
        // draw gradient
        let FEVreadingPts = FEVdataPoints.map({(r) -> Double in r.reading})
        print("the FEVreadingPts are " + String(FEVreadingPts))
        // margin for left and right
        let margin:CGFloat = 20.0
        let width:CGFloat = rect.width
        let height:CGFloat = rect.height
        print("the rect width is \(width) and height is \(height)")
        // draw background gradient
        let context = UIGraphicsGetCurrentContext()
        let startPoint = CGPoint(x: 0, y: rect.height)
        let endPoint = CGPoint(x: 0, y: 0)
        var colors = [UIColor.redColor().CGColor, UIColor.redColor().CGColor, UIColor.yellowColor().CGColor, UIColor.greenColor().CGColor]
        var locations:[CGFloat] = [0, 0.45, 0.65, 1]
        var gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors, locations)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, [])
        self.addSubview(centralText)
        centralText.adjustsFontSizeToFitWidth = true
        centralText.textAlignment = NSTextAlignment.Center
        centralText.text = ""
        
        if FVCdata <= 0 {
            centralText.text = "No FVC data"
        }
        else if FEVreadingPts.maxElement() >= FVCdata {
            centralText.text = "Wrong data: FVC must be greater than FEV"
        }
        else if FEVreadingPts.minElement() == -1 && FEVreadingPts.maxElement() <= 0 {
            centralText.text = "No FEV data"
        }
        else {
            if FEVdataPoints.count != 7 {
                fatalError("Error: The number of data points are not 7")
            }
            let graphPoints = FEVreadingPts.map({(n) -> Double in n / FVCdata})
            let columnXpoint = { (column: Int) -> CGFloat in
                let spacer: CGFloat = (width - 2 * margin)/CGFloat((graphPoints.count - 1))
                return margin + CGFloat(column) * spacer
            }
            let columnYpoint = { (column: Int) -> CGFloat in
                if graphPoints[column] <= 0 {
                    return -1
                }
                else {
                    // need to flip the height
                    return height - (height * CGFloat(graphPoints[column]))
                }
            }
            // draw the line graph
            
            UIColor.whiteColor().setFill()
            UIColor.whiteColor().setStroke()
            // setup the points line
            let graphPath = UIBezierPath()
            
            var needsShadow = false
            var firstPoint: CGPoint = CGPoint.zero
            var firstPointFound = false
            // move to first point and move to each point (adding line)
            for i in 0..<graphPoints.count {
                if columnYpoint(i) > 0 && !firstPointFound {
                    firstPoint = CGPoint(x: columnXpoint(i), y: columnYpoint(i))
                    graphPath.moveToPoint(firstPoint)
                    print("the first pt is \(CGPoint(x: columnXpoint(i), y: columnYpoint(i)))")
                    firstPointFound = true
                    continue
                }
                if columnYpoint(i) > 0 && firstPointFound {
                    let nextPoint = CGPoint(x: columnXpoint(i), y: columnYpoint(i))
                    print("the pt is \(CGPoint(x: columnXpoint(i), y: columnYpoint(i)))")
                    graphPath.addLineToPoint(nextPoint)
                    needsShadow = true
                }
            }
            graphPath.stroke()
            // display shadow if needed 
            if needsShadow {
                //Create the clipping path for the graph gradient
                
                //1 - save the state of the context (commented out for now)
                CGContextSaveGState(context)
                let clippingPath = graphPath.copy() as! UIBezierPath
                clippingPath.addLineToPoint(CGPoint(x: clippingPath.currentPoint.x, y: height))
                clippingPath.addLineToPoint(CGPoint(x: firstPoint.x, y: height))
                clippingPath.closePath()
                clippingPath.addClip()
                
                let startPoint = CGPoint.zero
                let endPoint = CGPoint(x: 0, y: height)
                colors = [UIColor.whiteColor().CGColor, UIColor.clearColor().CGColor]
                locations = [0, 1]
                gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors, locations)
                CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, [])
                CGContextRestoreGState(context)
                
                //draw the line on top of the clipped gradient
                graphPath.lineWidth = 2.0
                graphPath.stroke()
            }
            for i in 0..<graphPoints.count {
                var point = CGPoint(x: columnXpoint(i), y: columnYpoint(i))
                point.x -= 5.0/2
                point.y -= 5.0/2
                let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: 5, height: 5)))
                circle.fill()
                // draw x labesl
                let percentLabel = UILabel.init(frame: CGRectMake(columnXpoint(i) - 14, height - 22, 35, 22))
                percentLabel.adjustsFontSizeToFitWidth = true
                let df = NSDateFormatter()
                df.dateFormat = "MMM dd"
                percentLabel.text = df.stringFromDate(self.FEVdataPoints[i].date)
                self.addSubview(percentLabel)
            }
            //Draw horizontal graph lines on the top of everything
            let linePath = UIBezierPath()
            // 4 lines with lables
            for i in 1..<5 {
                linePath.moveToPoint(CGPoint(x: margin, y: CGFloat(CGFloat(i) * 0.2 * height)))
                linePath.addLineToPoint(CGPoint(x: width - margin, y: CGFloat(CGFloat(i) * 0.2 * height)))
                // draw y labesl
                let percentLabel = UILabel.init(frame: CGRectMake(0, CGFloat(i) * 0.2 * height - 15, 22, 22))
                percentLabel.adjustsFontSizeToFitWidth = true
                percentLabel.text = "\(100 - i * 20)%"
                self.addSubview(percentLabel)
            }
            UIColor(white: 1.0, alpha: 0.5).setStroke()
            linePath.lineWidth = 1.0
            linePath.stroke()
            
            // draw labels 
            
        }
        
        
        
        
        
    }
    
    func queryFEVAndUpdate() {
        print(" called from queryFEVAndUpdate")
        let calendar = NSCalendar.currentCalendar()
        // set anchor date to be 12:00 am of last week
        let lastWeekDate = calendar.dateByAddingUnit(.Day, value: -6, toDate: NSDate(), options: [])
        let anchorComponents = calendar.components([.Day, .Month, .Year], fromDate: lastWeekDate!)
        guard let anchorDate = calendar.dateFromComponents(anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        let interval = NSDateComponents()
        interval.day = 1
        let query = HKStatisticsCollectionQuery(quantityType: FEVhealthType, quantitySamplePredicate: nil, options: .DiscreteAverage, anchorDate: anchorDate, intervalComponents: interval)
        // set query result handler
        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else {
                fatalError("*** An error occurred while calculating the statistics: \(error?.localizedDescription) ***")
            }
            dispatch_async(dispatch_get_main_queue()) {
                print("called from inside of FEV query completion handler")
                self.FEVdataPoints.removeAll()
                let startDate = anchorDate
                let endDate = calendar.dateByAddingUnit(.Second, value: -2, toDate: NSDate(), options: [])
                statsCollection.enumerateStatisticsFromDate(startDate, toDate: endDate!, withBlock: {statistics, stop in
                    if let quantity = statistics.averageQuantity() {
                        let value = Double(quantity.doubleValueForUnit(HKUnit.literUnit()))
                        let date = statistics.startDate
                        self.FEVdataPoints.append(Reading(date: date, location: "", reading: value))
                        
                    }
                    else {
                        self.FEVdataPoints.append(Reading(date: statistics.startDate, location: "", reading: -1))
                    }
                    //if (self.FEVdataPoints.count)
                    print(String(statistics.startDate))
                    print("the FEVdataPoints called from query result handler is \(self.FEVdataPoints)")
                    self.queryComplete[0] = true
                    if self.queryComplete[1] && self.needsRefresh {
                        self.queryComplete[0] = false; self.queryComplete[1] = false
                        self.setNeedsDisplay()
                        self.needsRefresh = false
                    }
                    
                })
            }
        }
        healthStore.executeQuery(query)
    }
    
    // query for FEV data and update FEVreadings[]
    func queryFVCAndUpdate() {
        let calendar = NSCalendar.currentCalendar()
        let endDate = NSDate()
        let startDate = calendar.dateByAddingUnit(.Day, value: -90, toDate: endDate, options: [])
        let sampleType = FVChealthType
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: [])
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: {(query, results, error) -> Void in
            guard let samples = results as? [HKQuantitySample] else {
                //print(String(error))
                fatalError("An error occured fetching the user's Data.  The error was: \(error?.localizedDescription)");
            }
            dispatch_async(dispatch_get_main_queue()) {
                var readings = [Reading]()
                print("the FVC readings count is \(readings) ")
                for sample in samples {
                    let location = ((sample.metadata?["location"]) != nil) ? sample.metadata?["location"] as? String : ""
                    let date = sample.startDate
                    let reading = sample.quantity.doubleValueForUnit(HKUnit.literUnit())
                    let readingItem = Reading.init(date: date, location: location!, reading: reading)
                    readings.append(readingItem)
                }
                if readings.count > 0 {
                    var sum:Double = 0
                    for r in readings {
                        sum += r.reading
                    }
                    self.FVCdata = sum / Double(readings.count)
                }
                else {
                    self.FVCdata = -1
                }
                self.queryComplete[1] = true
                if self.queryComplete[0] && self.needsRefresh {
                    self.queryComplete[0] = false; self.queryComplete[1] = false
                    self.setNeedsDisplay()
                    self.needsRefresh = false
                }
            }
        })
        
        healthStore.executeQuery(query)
    }
    
    func drawLabel(xPos: CGFloat, yPos: CGFloat, width: CGFloat, height: CGFloat, labelStr: String ) -> UILabel {
        let label = UILabel.init(frame: CGRectMake(xPos, yPos, width, height))
        label.adjustsFontSizeToFitWidth = true
        label.text = labelStr
        label.textAlignment = NSTextAlignment.Center
        self.addSubview(label)
        return label
    }
    
    
}
