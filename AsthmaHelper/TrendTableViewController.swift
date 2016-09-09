//
//  TrendTableViewController.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 6/15/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import UIKit
import HealthKit

class TrendTableViewController: UITableViewController {
    
    @IBOutlet weak var ChartView: ChartUIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let chartReadings = ChartReadings.init()
    
    var trendInterval = 7
    
    var FVCinterval = 90
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(chartViewSetup), name: UIApplicationWillEnterForegroundNotification, object: nil)
        segmentedControl.addTarget(self, action: #selector(onTrendIntervalChange), forControlEvents: .ValueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ChartView.layoutIfNeeded()
        renderChartViewStaticContent()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        chartViewSetup()
    }
    
    func chartViewSetup() {
        ChartView.window?.frame.size.width = (self.view.window?.frame.size.width)!
        
        let authChecker = AuthChecker()
        if authChecker.FEVandFVCbothAuthorized() {
            ChartView.centralLabel.text = "loading"
            let successHandler = {self.prepareAndRender()}
            let FEVfailHandler = {self.displayFetchingError("FEV")}
            chartReadings.getFEVchartReadings(trendInterval, successHandler: successHandler, failHandler: FEVfailHandler)
            let FVCfailHandler = {self.displayFetchingError("FVC")}
            chartReadings.getAvgFVC(FVCinterval, successHandler: successHandler, failHandler: FVCfailHandler)
        } else {
            // since HeakthKit auth pop up only happens at the first view
            // -> will never exe successHandler
            authChecker.askPermission(self, askCompleteHandler: {})
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }
    
    override func tableView( tableView: UITableView,
                             didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func displayFetchingError(type: String) {
        ControllerUtil.displayAlert(self, title: "Error", msg: "Error fetching \(type) Data")
    }
    
    func prepareAndRender() {
        
        let FEVreadingPts = chartReadings.FEVlist.map{$0.reading}
        let avgFVC = chartReadings.avgFVC.reading
        var centralText = ""
        var graphPts:[Double] = []
        if avgFVC <= 0 {
            centralText = "No FVC data"
        }
        else if FEVreadingPts.maxElement() >= avgFVC {
            centralText = "Wrong data: FVC must be greater than FEV"
        }
        else if FEVreadingPts.minElement() == -1 && FEVreadingPts.maxElement() < 0 {
            centralText = "No FEV data"
        }
        else {
            graphPts = FEVreadingPts.map({$0 / avgFVC})
            // tmp
            /*
            graphPts = [0, 0.5, 0.98, 1]
            
            graphPts.removeAll()
            for var i in 0..<90 {
                graphPts.append(0.2 + 0.01 * Double(i))
            } */
            // end tmp
        }
        ChartView.setNeedsDisplay()
        renderChartView(centralText, graphPts: graphPts)
    }
    
    func renderChartViewStaticContent() {
        ChartView.titleLabel.text = "FEV%"
        ChartView.yUnitLabel.text = "(%)"
        renderChartViewXaxisLabels()
    }
    
    func renderChartViewXaxisLabels() {
        // render x labels based on trend Interval
        let width = ChartView.frame.size.width
        let height = ChartView.frame.size.height
        ChartView.setXaxis(width, height: height, intervalCount: trendInterval, labelClosure: {
            let calendar = NSCalendar.currentCalendar()
            
            let resultDate = calendar.dateByAddingUnit(.Day, value: -self.trendInterval + $0 + 1, toDate: NSDate(), options: [])!
            let df = NSDateFormatter()
            df.dateFormat = "MMM dd"
            return df.stringFromDate(resultDate)
        } )
    }
    
    func renderChartView(centralText: String, graphPts: [Double]) {
        ChartView.centralLabel.text = centralText
        ChartView.graphPts = graphPts
    }
    
    func onTrendIntervalChange() {
        let selctedTitle = segmentedControl.titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex)!
        switch selctedTitle {
        case "1 Week":
            trendInterval = 7
        case "2 Week":
            trendInterval = 14
        case "1 Month":
            trendInterval = 30
        case "3 Month":
            trendInterval = 90
        default:
            trendInterval = 7
        }
        renderChartViewXaxisLabels()
        chartViewSetup()
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
