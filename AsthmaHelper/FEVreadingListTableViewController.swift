//
//  FEVreadingListTableViewController.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 5/22/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import UIKit
import HealthKit


class FEVreadingListTableViewController: UITableViewController {

    
    // to store either FEV or FVC readings
    var readings: Readings?
    
    // to store the current sample to be deleted
    var currentSample : HKSample?
    
    // to determine if it is FEV data or FVC data 
    var dataType: HKSampleType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup based on if it is FEV or FVC
        guard let barTitle = self.parentViewController?.tabBarItem.title else {
            fatalError("Error: unable to get tab title")
        }
        if barTitle == "FEV Data Reading" {
            self.dataType = Readings.FEVhealthType
            self.navigationItem.title = barTitle
        }
        else {
            self.dataType = Readings.FVChealthType
            self.navigationItem.title = barTitle
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(readingRefresh), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        readings = Readings(healthType: dataType!)
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func readingRefresh() {
        let authChecker = AuthChecker()
        let askCompleteHandler = {() -> Void in
            if authChecker.checkAuthStatusFor(self.dataType!) {
                self.readings?.getReadings({self.tableView.reloadData()})
            }
        }
        if Readings.healthStore.authorizationStatusForType(dataType!) == HKAuthorizationStatus.SharingAuthorized {
            // query for FEV reading data
            //readings?.getReadings({self.tableView.reloadData()})
            askCompleteHandler()
        } else {
            
            authChecker.askPermission(self, askCompleteHandler: askCompleteHandler)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        readingRefresh()
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
        return (readings?.list.count)!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        // Configure the cell...
        let reading = (readings?.list[indexPath.row])!
        cell.textLabel?.text = reading.getDateAndTimeStr()
        cell.detailTextLabel?.text = String(reading.reading) + " L"
        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let toBeDeletedReading = (readings?.list[indexPath.row])!
            if toBeDeletedReading.source == HKSource.defaultSource() {
                let successClosure = {
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
                let failClosure = { (error: NSError?) -> Void in
                    var msg = "Error deleting data"
                    if let error = error {
                        msg = msg + ": " + error.localizedDescription
                    }
                    ControllerUtil.displayAlert(self, title: "Error", msg: msg )
                }
                readings?.deleteReading(toBeDeletedReading.id, successHandler: successClosure, failHandler: failClosure)
            } else {
                ControllerUtil.displayAlert(self, title: "Delete Data", msg: "Error deleting data: Cannot delete data that is not generated by this app. \n The data can be deleted inside Apple's Health app")
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    func displayAlert(title: String, msg: String) -> Void {
        let alert = UIAlertController.init(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showDetail" {
            let readingDetailViewController = segue.destinationViewController as! FEVreadingTableViewController
            readingDetailViewController.dataType = dataType
            if let selectedCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(selectedCell)
                let selectedReading = readings?.list[(indexPath?.row)!]
                readingDetailViewController.reading = selectedReading
            }
        }
        else if segue.identifier == "addItem" {
            let readingDetailViewController = segue.destinationViewController.childViewControllers[0] as! FEVreadingTableViewController
            readingDetailViewController.dataType = dataType
        }
        
    }
    
    @IBAction func unwindToReadingList(sender: UIStoryboardSegue) {
        
    }

}
