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
    var readings = [Reading]()
    // to be used to access healthkit database
    var healthStore = HKHealthStore()
    // to store the current sample to be deleted
    var currentSample : HKSample?
    
    let FEVhealthType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierForcedExpiratoryVolume1)!
    
    let FVChealthType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierForcedVitalCapacity)!
    
    // to determine if it is FEV data or FVC data 
    var dataType: HKSampleType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup based on if it is FEV or FVC
        guard let barTitle = self.parentViewController?.tabBarItem.title else {
            fatalError("Error: unable to get tab title")
        }
        if barTitle == "FEV Data Reading" {
            self.dataType = FEVhealthType
            self.navigationItem.title = barTitle
        }
        else {
            self.dataType = FVChealthType
            self.navigationItem.title = barTitle
        }
        
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.healthStore.authorizationStatusForType(dataType!) == HKAuthorizationStatus.SharingAuthorized {
            // query for FEV reading data
            queryAndUpdate()
        }
        print("the size of readings is \(readings.count)")
        
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
        return readings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        // Configure the cell...
        let reading = readings[indexPath.row]
        cell.textLabel?.text = reading.getDateAndTimeStr()
        cell.detailTextLabel?.text = String(reading.reading) + " L"
        return cell
    }

    
    
    
    // query for FEV data and update FEVreadings[]
    func queryAndUpdate() {
        let calendar = NSCalendar.currentCalendar()
        let endDate = NSDate()
        let startDate = calendar.dateByAddingUnit(.Day, value: -90, toDate: endDate, options: [])
        /*
        guard let sampleType = dataType else {
            fatalError("*** This method should never fail ***")
        } */
        guard let sampleType = dataType else { fatalError("the datatype is not assigne.") }
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: [])
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: {(query, results, error) -> Void in
            guard let samples = results as? [HKQuantitySample] else {
                //print(String(error))
                fatalError("An error occured fetching the user's Data.  The error was: \(error?.localizedDescription)");
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.readings.removeAll()
                var i = 0
                for sample in samples {
                    i += 1
                    let location = ((sample.metadata?["location"]) != nil) ? sample.metadata?["location"] as? String : ""
                    let date = sample.startDate
                    let reading = sample.quantity.doubleValueForUnit(HKUnit.literUnit())
                    let id = sample.UUID
                    let readingItem = Reading.init(date: date, location: location!, reading: reading, id: id)
                    self.readings.append(readingItem)
                }
                print("the sample loop is executed \(i) times ")
                self.tableView.reloadData()
            }
        })
        
        healthStore.executeQuery(query)
    }
    
    func deleteDatafromHealthStore(reading: Reading, indexPath: NSIndexPath) -> Void {
        let calendar = NSCalendar.currentCalendar()
        let startDate = reading.date
        let endDate = calendar.dateByAddingUnit(.Second, value: 1, toDate: startDate, options: [])
        guard let sampleType = dataType else {
            fatalError("*** This method should never fail ***")
        }
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: [])
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: {(query, results, error) -> Void in
            guard let samples = results as? [HKQuantitySample] else {
                //print(String(error))
                fatalError("An error occured fetching the user's Data.  The error was: \(error?.localizedDescription)");
            }
            dispatch_async(dispatch_get_main_queue()) {
                //self.currentSample = samples.first
                print(samples.first)
                print(samples.first?.sourceRevision.source)
                print(samples.first?.sourceRevision.source == HKSource.defaultSource())
                if samples.first?.sourceRevision.source == HKSource.defaultSource() {
                    self.healthStore.deleteObject(samples.first!, withCompletion: {(success, error) -> Void in
                        dispatch_async(dispatch_get_main_queue()) {
                            if !success {
                                self.displayAlert("Delete Data", msg: "Error deleting data: \(error)")
                                print("Error deleting data: \(error)")
                                
                                abort()
                            }
                            else {
                                self.readings.removeAtIndex(indexPath.row)
                                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                print("data deleted")
                            }
                        }
                        
                    })
                }
                else {
                    self.displayAlert("Delete Data", msg: "Error deleting data: Cannot delete data that is not generated by this app. \n The data can be deleted inside Apple's Health app")
                }
                
            }
        })
        healthStore.executeQuery(query)
        
        
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
            let toBeDeletedReading = readings[indexPath.row]
            deleteDatafromHealthStore(toBeDeletedReading, indexPath: indexPath)
            
            
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
                let selectedReading = readings[(indexPath?.row)!]
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
