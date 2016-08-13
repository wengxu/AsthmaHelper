//
//  FEVreadingTableViewController.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 5/22/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit

class FEVreadingTableViewController: UITableViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    @IBOutlet weak var dateTableViewCell: UITableViewCell!
    @IBOutlet weak var timeTableViewCell: UITableViewCell!
    @IBOutlet weak var locationTableViewCell: UITableViewCell!

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var FEVreadingTextField: UITextField!
    
    //  deprecated now(not being called)
    @IBAction func addAction(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    let locMan: CLLocationManager = CLLocationManager()
    // to be used to access healthkit database
    var healthStore = HKHealthStore()
    
    // to store the FEVreading object that is associated with the current view
    var reading: Reading?
    
    let FEVhealthType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierForcedExpiratoryVolume1)!
    
    let FVChealthType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierForcedVitalCapacity)!
    
    // to determine if it is FEV data or FVC data
    var dataType: HKSampleType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup title based on if it is FEV or FVC
        self.navigationItem.title = dataType!.description.stringByReplacingOccurrencesOfString("HKQuantityTypeIdentifier", withString: "")
        
        // setup FEV reading textfield
        FEVreadingTextField.delegate = self
        // if editing a FEV reading
        if let reading = reading {
            // update cancel and add button 
            cancelButton.title = "Back"
            addButton.title = ""
            addButton.enabled = false
            
            dateTableViewCell.detailTextLabel?.text = reading.getDateStr()
            timeTableViewCell.detailTextLabel?.text = reading.getTimeStr()
            locationTextField.text = reading.location
            locationTextField.enabled = false
            FEVreadingTextField.text = String(reading.reading)
            FEVreadingTextField.enabled = false
        }
        // if adding a FEV reading
        else {
            // setup
            addButton.enabled = false
            let df = NSDateFormatter()
            df.dateFormat = "MMM dd, yyyy"
            dateTableViewCell.detailTextLabel?.text = df.stringFromDate(NSDate())
            df.dateFormat = "h:mm a"
            timeTableViewCell.detailTextLabel?.text = df.stringFromDate(NSDate())
            reading = Reading(date: NSDate(), location: "", reading: 0)
            //locationTableViewCell.detailTextLabel?.text = ""
            
            // setup location
            locMan.delegate = self
            locMan.requestWhenInUseAuthorization()
            locMan.startUpdatingLocation()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return 4
    }
    
    override func tableView( tableView: UITableView,
                             didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        clearInputUIs()
        switch indexPath.row {
        case 2:
            locationTextField.becomeFirstResponder()
        case 3:
            FEVreadingTextField.becomeFirstResponder()
        default:
            print("\(indexPath.row) th row selected ")
        }
    }
    
    
    // if unable to get location
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        if error.code == CLError.Denied.rawValue {
            locMan.stopUpdatingLocation()
        }
        else {
            print("lcoation did update is not called due to network or unknown location")
        }
    }
    
    // if successfully get location 
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations[0]
        if newLocation.horizontalAccuracy >= 0 {
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(newLocation, completionHandler: {(placemarks, error) -> Void in
                // if conversion success
                if error == nil {
                    let addressDic = placemarks![0].addressDictionary
                    print(addressDic)
                    if let street = addressDic!["Street"], city = addressDic!["City"], state = addressDic!["State"], zip = addressDic!["ZIP"] {
                        self.locationTextField.text = "\(street), \(city), \(state) \(zip)"
                    }
                }
                
            })
            //locationTableViewCell.detailTextLabel?.text = "lat: \(newLocation.coordinate.latitude), long: \(newLocation.coordinate.longitude)"
            locMan.stopUpdatingLocation()
            print("lcoation did update is called")
            FEVreadingTextField.becomeFirstResponder()
        }
     }
    
    // textfield functions
    
    // disable add button when nothing is entered in FEV reading row
    func textField( textField: UITextField,
                     shouldChangeCharactersInRange range: NSRange,
                                                   replacementString string: String) -> Bool {
        // prevent multiple dots
        if range.location != 0 {
            if textField.text?.rangeOfString(".")?.count == 1 && string == "." {
                return false
            }
        }
        if NSEqualRanges(range, NSRangeFromString("0...0")) && string != "." {
            addButton.enabled = true
        }
        if NSEqualRanges(range, NSRangeFromString("1...0")) {
            addButton.enabled = true
        }
        // check if only "." is shown on textfield. If yes, disable add button
        if NSEqualRanges(range, NSRangeFromString("1...1"))  {
            let textStr = textField.text
            let firstStr = textStr!.substringToIndex((textStr?.startIndex.advancedBy(1))!)
            if firstStr == "." {
                addButton.enabled = false
            }
        }
        // if nothing is on textfield
        if NSEqualRanges(range, NSRangeFromString("0...1")) {
            addButton.enabled = false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField ) -> Bool {
        clearInputUIs()
        return true;
    }
    
    func clearInputUIs() -> Void {
        locationTextField.resignFirstResponder()
        FEVreadingTextField.resignFirstResponder()
    }
    
    // healthKit 
    func saveDataIntoHealthStore(reading: Double, recordDate: NSDate, locationStr: String) -> Void {
        // save the user's FEV reading into HealthKit
        //let FEVvolumeType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierForcedExpiratoryVolume1)
        let literUnit = HKUnit.literUnit()
        let quantity = HKQuantity.init(unit: literUnit, doubleValue: reading)
        //let df = NSDateFormatter()
        //df.dateFormat = "MMM dd, yyyy h:mm a"
        //let recordDate = df.dateFromString(dateStr)
        let quantitySample = HKQuantitySample.init(type: dataType as! HKQuantityType, quantity: quantity, startDate: recordDate, endDate: recordDate, device: HKDevice.localDevice(), metadata: ["location": locationStr])
        healthStore.saveObject(quantitySample, withCompletion: {(success, error) -> Void in
            if !success {
                self.displayAlert("Saving Data", msg: "Error Saving data: \(error)")
                abort()
            }
            else {
                print("data saved")
            }
        })
    }
    
    // custom display alert function
    func displayAlert(title: String, msg: String) -> Void {
        let alert = UIAlertController.init(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        FEVreadingTextField.resignFirstResponder()
        if sender === addButton {
            reading?.location = locationTextField.text!
            reading?.reading = Double(FEVreadingTextField.text!)!
            saveDataIntoHealthStore((reading?.reading)!, recordDate: (reading?.date)!, locationStr: (reading?.location)!)
            print("data saved to HealthKit")
        }
    
    }
    
    
    

}
