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
    
    let chartReadings = ChartReadings.init()
    
    var trendInterval = 7
    
    var FVCinterval = 90
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderChartViewStaticContent()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(chartViewSetup), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        chartViewSetup()
    }
    
    func chartViewSetup() {
        ChartView.window?.frame.size.width = (self.view.window?.frame.size.width)!
        
        let successHandler = {self.prepareAndRender()}
        let FEVfailHandler = {self.displayFetchingError("FEV")}
        chartReadings.getFEVchartReadings(trendInterval, successHandler: successHandler, failHandler: FEVfailHandler)
        let FVCfailHandler = {self.displayFetchingError("FVC")}
        chartReadings.getAvgFVC(FVCinterval, successHandler: successHandler, failHandler: FVCfailHandler)
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
        return 5
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
        //tmp
        for var i in 0..<chartReadings.FEVlist.count {
            print("the FEV list reading at \(i) is \(chartReadings.FEVlist[i])")
        }
        for var i in 0..<FEVreadingPts.count {
            print("the FEVreadingPts at \(i) is \(FEVreadingPts[i])")
        }
        //end tmp
        let avgFVC = chartReadings.avgFVC.reading
        var centralText = ""
        var graphPts:[Double] = []
        if avgFVC <= 0 {
            centralText = "No FVC data"
        }
        else if FEVreadingPts.maxElement() >= avgFVC {
            centralText = "Wrong data: FVC must be greater than FEV"
        }
        else if FEVreadingPts.minElement() == -1 && FEVreadingPts.maxElement() <= 0 {
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
            ChartView.setNeedsDisplay()
        }
        renderChartView(centralText, graphPts: graphPts)
    }
    
    func renderChartViewStaticContent() {
        ChartView.titleLabel.text = "FEV%"
        ChartView.yUnitLabel.text = "(%)"
        ChartView.centralLabel.text = "loading"
    }
    
    func renderChartView(centralText: String, graphPts: [Double]) {
        ChartView.centralLabel.text = centralText
        ChartView.graphPts = graphPts
        // render x labels 
        let width = ChartView.frame.size.width
        let height = ChartView.frame.size.height
        ChartView.setXaxis(width, height: height, labelClosure: {
            
            let resultDate = self.chartReadings.FEVlist[$0].date
            let df = NSDateFormatter()
            df.dateFormat = "MMM dd"
            return df.stringFromDate(resultDate)
        } )
        
        
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
