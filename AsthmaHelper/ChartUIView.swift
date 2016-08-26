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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let width = self.frame.size.width
        let height = self.frame.size.height
        titleLabel.frame = CGRectMake(width * 0.2, 0, width * 0.8, height * 0.2)
        centralLabel.frame = CGRectMake(width * 0.2, height * 0.2, width * 0.6 , height * 0.6)
        yUnitLabel.frame = CGRectMake(0, 0, 40, 20)
        setAxis(width, height: height)
        
    }
    
    var graphPts:[Double] = []
    
    // top, right, buttom, left margin(the part that is not touched by graph pts and lines)
    let margin:[CGFloat] = [0, 20, 0, 20]
    
    // central label to show if there is any error to display
    let centralLabel = UILabel.init()
    
    let titleLabel = UILabel.init()
    
    let yUnitLabel = UILabel.init()
    
    let yIntervalCount = 5
    
    var xReadingLabels = [UILabel]()
    
    var yRange = NSRange.init(location: 0, length: 100)
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        drawGradient(rect, context: context)
        
        setTitleLabel()
        setCentralLabel()
        
        let width:CGFloat = rect.width
        let height:CGFloat = rect.height
        
        
        if centralLabel.text == "" {
            let (needShadow, graphPath, firstPt) = drawLine(width, height: height)
            if needShadow {
                drawShadow(width, height: height, context: context, graphPath: graphPath, firstPt: firstPt)
            }
            drawPoints(width, height: height)
            drawHorizontalLines(width, height: height)
        }
    }
    
    func drawGradient(rect: CGRect, context: CGContext) {
        let red = UIColor.redColor().CGColor
        let yellow = UIColor.yellowColor().CGColor
        let green = UIColor.greenColor().CGColor
        // draw background gradient
        
        let startPoint = CGPoint(x: 0, y: rect.height)
        let endPoint = CGPoint(x: 0, y: 0)
        //let colors = [red, red, yellow, green, green]
        let colors = [red, red, yellow, green]
        let locations:[CGFloat] = [0, 0.45, 0.65, 1]
        // adjust for top and buttom margins
        //let locations:[CGFloat] = [0, 0.42, 0.58, 0.86, 1]
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors, locations)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, [])
    }
    
    func setTitleLabel() {
        self.addSubview(titleLabel)
        // use tmpFrame set text center
        var tmpFrame = titleLabel.frame
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        titleLabel.textAlignment = NSTextAlignment.Center
        tmpFrame.size.height = titleLabel.frame.size.height
        titleLabel.frame = tmpFrame
    }
    
    func setCentralLabel() {
        self.addSubview(centralLabel)
        centralLabel.textAlignment = NSTextAlignment.Center
        centralLabel.numberOfLines = 2
    }
    
    func setAxis(width: CGFloat, height: CGFloat) {
        
        setXaxis(width, height: height, intervalCount: 0, labelClosure: {String($0)})
        
        setYaxis(width, height: height)
    }
    
    func setXaxis(width: CGFloat, height: CGFloat, intervalCount: Int, labelClosure: (Int) -> String) {
        
        print("the x axis label count before is \(xReadingLabels.count)")
        print("the intervalCount in setXaxis is \(intervalCount)")
        let yCoord = margin[2] == 0 ? height - CGFloat(10) : height - margin[2] / CGFloat(2)
        let startPt = CGPoint(x: margin[3], y: yCoord)
        let endPt = CGPoint(x: width - margin[1], y: yCoord)
        removeXreadingLabels()
        // add x reading labels that render based on number of intervalCounts
        if intervalCount > 1 {
            let xRange = NSRange.init(location: 0, length: intervalCount - 1)
            let (intervalCount, remainder) = getIntervalCount(xRange.length)
            let intervalLength = (xRange.length - remainder) / intervalCount
            let viewLength = endPt.x - startPt.x
            let viewUnitInvervalLength = viewLength / CGFloat(xRange.length)
            let viewIntervalLength = viewUnitInvervalLength * CGFloat(intervalLength)
            for i in 0...intervalCount {
                var labelCenterX = startPt.x + viewIntervalLength * CGFloat(i)
                if i != 0 {
                    labelCenterX = labelCenterX + viewUnitInvervalLength * CGFloat(remainder)
                }
                let labelCenter = CGPoint(x: labelCenterX, y: startPt.y)
                var xReading = yRange.location + i * intervalLength
                if i != 0 {
                    xReading = xReading + remainder
                }
                let text = labelClosure(xReading)
                // tmp
                if i == intervalCount {
                    var a = 0
                    a = a + 1
                }
                // end tmp
                let xReadingLabel = createReadingLabelAt(labelCenter, text: text)
                xReadingLabels.append(xReadingLabel)
                addSubview(xReadingLabel)
            }
        }
        
        print("the x axis label count after is \(xReadingLabels.count)")
        
    }
    
    func setYaxis(width: CGFloat, height: CGFloat) -> Int {
        let startPt = CGPoint(x: margin[3] / 2, y: height - margin[2])
        let endPt = CGPoint(x: margin[3] / 2, y: margin[0])
        
        self.addSubview(yUnitLabel)
        // add y readings label that render based on y range
        let intervalCount = yIntervalCount
        let intervalLength = Double(yRange.length) / Double(intervalCount)
        let viewLength = endPt.y - startPt.y
        let viewIntervalLength = viewLength / CGFloat(intervalCount)
        for i in 1..<intervalCount {
            let labelCenter = CGPoint(x: startPt.x, y: startPt.y + viewIntervalLength * CGFloat(i))
            let yReading = Double(yRange.location) + Double(i) * intervalLength
            let text = String(format: "%.0f", yReading)
            let yReadingLabel = createReadingLabelAt(labelCenter, text: text)
            addSubview(yReadingLabel)
            print("the y axis label font size is \(yReadingLabel.font.pointSize)")
        }
        return intervalCount
    }
    
    // get the interval count for x-axis readings
    // return [intervalCount, remainder]
    func getIntervalCount(length: Int) -> (Int, Int) {
        var result = (0, 0)
        let maxIntervalCount = 4
        if length <= maxIntervalCount - 1 {
            result = (length, 0)
        } else {
            for i in (2...maxIntervalCount).reverse() {
                // remainder == 0 or 1 could be optimal division 
                // guaranteed to find result since the last i is 2
                let rem = length % i
                if rem == 0 || rem == 1 {
                    result = (i, rem)
                    break
                }
            }
        }
        return result
    }
    
    func removeXreadingLabels() {
        while xReadingLabels.count > 0 {
            let labelView = xReadingLabels.popLast()
            labelView?.removeFromSuperview()
        }
    }
    
    func createReadingLabelAt(center: CGPoint, text: String) -> UILabel {
        let labelWidth: CGFloat = 40
        let labelHeight: CGFloat = 20
        let halfLabelWidth = labelWidth / CGFloat(2)
        let halfLabelHeight = labelHeight / CGFloat(2)
        let tmpFrame = CGRectMake(center.x - halfLabelWidth, center.y - halfLabelHeight, labelWidth, labelHeight)
        let readingLabel = UILabel.init(frame: tmpFrame)
        readingLabel.text = text
        readingLabel.adjustsFontSizeToFitWidth = true
        readingLabel.frame.size.width = tmpFrame.size.width
        readingLabel.textAlignment = NSTextAlignment.Center
        // tmp 
        var readingLabelFrameSize = readingLabel.frame.size
        // end tmp
        return readingLabel
    }
    
    // draw line and return if shadow is needed
    func drawLine(width: CGFloat, height: CGFloat) -> (Bool, UIBezierPath, CGPoint) {
        let columnXpoint = { (column: Int) -> CGFloat in
            let spacer: CGFloat = (width - self.margin[1] - self.margin[3]) / CGFloat((self.graphPts.count - 1))
            return self.margin[3] + CGFloat(column) * spacer
        }
        let columnYpoint = { (column: Int) -> CGFloat in
            /*
            if self.graphPts[column] < 0 {
                return -1
            }
            else {
                // need to flip the height
                return height - (height * CGFloat(self.graphPts[column]))
            }*/
            self.graphPts[column] < 0 ? -1 : height - (height * CGFloat(self.graphPts[column]))
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
        for i in 0..<graphPts.count {
            if columnYpoint(i) >= 0 && !firstPointFound {
                firstPoint = CGPoint(x: columnXpoint(i), y: columnYpoint(i))
                graphPath.moveToPoint(firstPoint)
                print("the first pt is \(CGPoint(x: columnXpoint(i), y: columnYpoint(i)))")
                firstPointFound = true
                continue
            }
            if columnYpoint(i) >= 0 && firstPointFound {
                let nextPoint = CGPoint(x: columnXpoint(i), y: columnYpoint(i))
                print("the pt is \(CGPoint(x: columnXpoint(i), y: columnYpoint(i)))")
                graphPath.addLineToPoint(nextPoint)
                needsShadow = true
            }
        }
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        return (needsShadow, graphPath, firstPoint)
    }
    
    func drawShadow(width: CGFloat, height: CGFloat, context: CGContext, graphPath: UIBezierPath, firstPt: CGPoint) {
        //Create the clipping path for the graph gradient
        
        //1 - save the state of the context (commented out for now)
        CGContextSaveGState(context)
        let clippingPath = graphPath.copy() as! UIBezierPath
        clippingPath.addLineToPoint(CGPoint(x: clippingPath.currentPoint.x, y: height))
        clippingPath.addLineToPoint(CGPoint(x: firstPt.x, y: height))
        clippingPath.closePath()
        clippingPath.addClip()
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: height)
        let colors = [UIColor(white: 1.0, alpha: 0.7).CGColor, UIColor.clearColor().CGColor]
        let locations: [CGFloat] = [0, 1]
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors, locations)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, [])
        CGContextRestoreGState(context)
        
        //draw the line on top of the clipped gradient
        //graphPath.lineWidth = 2.0
        //graphPath.stroke()
    }
    
    func drawPoints(width: CGFloat, height: CGFloat) {
        let columnXpoint = { (column: Int) -> CGFloat in
            let spacer: CGFloat = (width - self.margin[1] - self.margin[3]) / CGFloat((self.graphPts.count - 1))
            return self.margin[3] + CGFloat(column) * spacer
        }
        let columnYpoint = { (column: Int) -> CGFloat in
            self.graphPts[column] < 0 ? -1 : height - (height * CGFloat(self.graphPts[column]))
        }
        for i in 0..<graphPts.count {
            var point = CGPoint(x: columnXpoint(i), y: columnYpoint(i))
            point.x -= 5.0/2
            point.y -= 5.0/2
            let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: 5, height: 5)))
            circle.fill()
            // draw x labesl
            /*
            let percentLabel = UILabel.init(frame: CGRectMake(columnXpoint(i) - 14, height - 22, 35, 22))
            percentLabel.adjustsFontSizeToFitWidth = true
            let df = NSDateFormatter()
            df.dateFormat = "MMM dd"
            percentLabel.text = df.stringFromDate(self.FEVdataPoints[i].date)
            self.addSubview(percentLabel)
            */
        }
    }
    
    func drawHorizontalLines(width: CGFloat, height: CGFloat) {
        let linePath = UIBezierPath()
        let yIntervalViewLength = height / CGFloat(yIntervalCount)
        // 4 lines with lables
        for i in 1..<yIntervalCount {
            let yHeight = CGFloat(i) * yIntervalViewLength
            linePath.moveToPoint(CGPoint(x: margin[3], y: yHeight))
            linePath.addLineToPoint(CGPoint(x: width - margin[1], y: yHeight))
            // draw y labesl
            /*
            let percentLabel = UILabel.init(frame: CGRectMake(0, CGFloat(i) * 0.2 * height - 15, 22, 22))
            percentLabel.adjustsFontSizeToFitWidth = true
            percentLabel.text = "\(100 - i * 20)%"
            self.addSubview(percentLabel)
            */
        }
        UIColor(white: 1.0, alpha: 0.5).setStroke()
        linePath.lineWidth = 1.0
        linePath.stroke()
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
