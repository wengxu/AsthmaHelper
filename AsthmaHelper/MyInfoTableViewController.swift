//
//  MyInfoTableViewController.swift
//  AsthmaHelper
//
//  Created by Xu Weng on 5/17/16.
//  Copyright © 2016 Xu Weng. All rights reserved.
//

import UIKit
import CoreData
import HealthKit

class MyInfoTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var DOBtableViewCell: UITableViewCell!
    @IBOutlet weak var heightTableViewCell: UITableViewCell!
    @IBOutlet weak var genderTableViewCell: UITableViewCell!
    @IBOutlet weak var nameTableViewCell: UITableViewCell!
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBAction func cancelAction(sender: AnyObject) {
        hideNavBarButtons()
        clearInputUIs()
        updateUserInfoLabels()
    }
    @IBAction func doneAction(sender: AnyObject) {
        clearInputUIs()
        hideNavBarButtons()
        updateUserInfoToDB()
    }
    
    var currentTableCellRow = -1
    var DOBpickerDataSource = [[Int]]()
    var heightPickerDataSource = [[Int]]()
    var genderPickerDataSource = ["Not Set", "Male", "Female"]
    var currentYear: Int = NSCalendar.currentCalendar().components([.Year], fromDate: NSDate()).year
    // to be used to access database
    var moc = DataController().managedObjectContext
    // to be used to access healthkit database
    var healthStore = HKHealthStore()
    
    let FEVhealthType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierForcedExpiratoryVolume1)!
    
    let FVChealthType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierForcedVitalCapacity)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initial set up
        self.nameTextField.delegate = self;
        self.nameTextField.autocorrectionType = UITextAutocorrectionType.No
        self.picker.delegate = self
        self.picker.dataSource = self
        
        currentYear = NSCalendar.currentCalendar().components([.Year], fromDate: NSDate()).year
        
        // hide nav bar buttons
        hideNavBarButtons();
        picker.hidden = true
        
        // try to fetch user info. If no user info exists, feed in user data 
        let userFetchReq = NSFetchRequest(entityName: "User")
        do {
            let fetchedUser = try moc.executeFetchRequest(userFetchReq) as! [User]
            if fetchedUser.count == 0 {
                seedUserInfo()
            }
            else {
                updateUserInfoLabels()
                
            }
            print("there are \(fetchedUser.count) user(s) in the DB")
            
        }
        catch {
            fatalError("Error fetched user \(error)")
        }
        askPermission()
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
        currentTableCellRow = indexPath.row
        // respond based on the table cell clicked 
        //print(NSString(format:"Hello, the section is %d and the row is %d", indexPath.section, indexPath.row))
        
        // setup nav bar buttons
        showNavBarButtons();
        
        switch indexPath.row {
        case 0:
            print("first row is selected")
            clearInputUIs()
            nameTextField.becomeFirstResponder()
            //nameTextField.end
            break;
        case 1:
            print("second row is selected")
            clearInputUIs()
            
            //let daysInMonth = ([] + (1...31)).map{(number) -> String in return String(number)}
            //let yearsInPicker = ([] + (currentYear-100...currentYear)).map{(number) -> String in return String(number)}
            let yearsInPicker = [] + (currentYear-100...currentYear)
            DOBpickerDataSource = [[] + (1...12),
                                   [] + (1...31),
                                   yearsInPicker]
            
            picker.tag = currentTableCellRow
            picker.reloadAllComponents()
            picker.hidden = false
            
            // move the picker to the right position
            if DOBtableViewCell.detailTextLabel?.text == "Not Set" {
                picker.selectRow(6, inComponent: 0, animated: true)
                picker.selectRow(15, inComponent: 1, animated: true)
                picker.selectRow(70, inComponent: 2, animated: true)
            }
            else {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"
                let DOBdate = dateFormatter.dateFromString((DOBtableViewCell.detailTextLabel?.text!)!)
                let month : Int = NSCalendar.currentCalendar().components([.Month], fromDate: DOBdate!).month
                let day : Int = NSCalendar.currentCalendar().components([.Day], fromDate: DOBdate!).day
                let year : Int = NSCalendar.currentCalendar().components([.Year], fromDate: DOBdate!).year
                picker.selectRow(month-1, inComponent: 0, animated: true)
                picker.selectRow(day-1, inComponent: 1, animated: true)
                picker.selectRow(DOBpickerDataSource[2].indexOf(year)!, inComponent: 2, animated: true)
                
            }
            
            
            break;
        case 2:
            print("third row (height) is selected")
            clearInputUIs()
            heightPickerDataSource = [[] + (0...9), [] + (0...11)]
            picker.tag = currentTableCellRow
            picker.reloadAllComponents()
            picker.hidden = false
            // move the picker to the right position
            if heightTableViewCell.detailTextLabel?.text == "Not Set" {
                picker.selectRow(5, inComponent: 0, animated: true)
                picker.selectRow(4, inComponent: 1, animated: true)
            }
            else {
                let heightStr = heightTableViewCell.detailTextLabel?.text
                let ftLength = Int(heightStr!.substringToIndex((heightStr?.startIndex.advancedBy(1))!))
                //let inLength = Int(heightStr!.substringWithRange(<#T##aRange: Range<Index>##Range<Index>#>)(heightStr!.startIndex.advancedBy(1))...heightStr?.endIndex)
                let inLength = Int((heightStr?.substringWithRange((heightStr?.startIndex.advancedBy(3))!..<(heightStr?.endIndex.advancedBy(-1))!))!)
                picker.selectRow(ftLength!, inComponent: 0, animated: true)
                picker.selectRow(inLength!, inComponent: 1, animated: true)
            }
        case 3:
            print("fourth row (gender) is selected")
            clearInputUIs()
            picker.tag = currentTableCellRow
            picker.reloadAllComponents()
            picker.hidden = false
            // move the picker to the right position
            let genderStr = genderTableViewCell.detailTextLabel?.text
            if genderStr != "Not Set" {
                picker.selectRow(genderPickerDataSource.indexOf(genderStr!)!, inComponent: 0, animated: true)
            }
        default:
            print("else")
            
        }
    }
    /* textfield functions */
    func textFieldShouldReturn(textField: UITextField ) -> Bool {
        textField.resignFirstResponder();
        //hideNavBarButtons();
        return true;
    }
    // when textfield is clicked
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        showNavBarButtons()
        currentTableCellRow = 0
        picker.tag = currentTableCellRow
        picker.hidden = true
        return true
    }
    
    func hideNavBarButtons() -> Void {
        // hide nav bar buttons
        doneButton.title = ""
        cancelButton.title = ""
        doneButton.enabled = false
        cancelButton.enabled = false
    }
    
    func showNavBarButtons() -> Void {
        // hide nav bar buttons
        doneButton.title = "Done"
        cancelButton.title = "Cancel"
        doneButton.enabled = true
        cancelButton.enabled = true
    }
    
    func clearInputUIs() -> Void {
        // hide keyboard and picker
        nameTextField.resignFirstResponder()
        picker.hidden = true
        
    }
    
    /* picker view functions */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        switch picker.tag {
        case 1:
            return 3
        case 2:
            return 2
        case 3:
            return 1
        default:
            return 1
        }
    }
    func pickerView(pickerView: UIPickerView,
                      numberOfRowsInComponent component: Int) -> Int {
        switch picker.tag {
        // DOB picker
        case 1:
            switch component {
            case 0:
                return 12
            case 1:
                return 31
            case 2:
                return 101
            default:
                return 1
            }
        // height picker
        case 2:
            switch component {
            case 0:
                return 10
            case 1:
                return 12
            default:
                return 1
            }
        // gender picker
        case 3:
            return 3
        default:
            return 1
        }
        
        
    }
    
    func pickerView( pickerView: UIPickerView,
                      titleForRow row: Int,
                                  forComponent component: Int) -> String? {
        switch pickerView.tag {
        // when date of birth cell from table is selected
        case 1:
            
            return (component == 0 ? NSDateFormatter().shortMonthSymbols[DOBpickerDataSource[component][row] - 1] : String(DOBpickerDataSource[component][row]))
        case 2:
            return (component == 0 ? String(heightPickerDataSource[component][row]) + " ft" : String(heightPickerDataSource[component][row]) + " in")
        case 3:
            return genderPickerDataSource[row]
        default:
            return "default"
        }
    }
    
    func pickerView( pickerView: UIPickerView,
                      didSelectRow row: Int,
                                   inComponent component: Int) {
        switch picker.tag {
        case 1:
            /* check if selection is a valid date, if not move to a valid date */
            var month = picker.selectedRowInComponent(0) + 1
            var day = picker.selectedRowInComponent(1) + 1
            var year = picker.selectedRowInComponent(2) + currentYear - 100
            while !isValidDate(month, day: day, year: year) {
                picker.selectRow(picker.selectedRowInComponent(1) - 1, inComponent: 1, animated: true)
                month = picker.selectedRowInComponent(0) + 1
                day = picker.selectedRowInComponent(1) + 1
                year = picker.selectedRowInComponent(2) + currentYear - 100
            }
            // get the date and set the label
            DOBtableViewCell.detailTextLabel?.text = NSDateFormatter().shortMonthSymbols[month - 1] + String(format: " %02d, ", day) + String(year)
        case 2:
            let ftLength = picker.selectedRowInComponent(0)
            let inLength = picker.selectedRowInComponent(1)
            heightTableViewCell.detailTextLabel?.text = String(format: "%d' %d\"", ftLength, inLength)
        case 3:
            genderTableViewCell.detailTextLabel?.text = genderPickerDataSource[row]
        default:
            return
        }
        
        
    }
    
    // check if the day month year is a valid date
    // can assume days are in [1...31]
    func isValidDate(month: Int, day: Int, year: Int) -> Bool {
        var result: Bool = false
        if [1,3,5,7,8,10,12].contains(month) {
            result = true
        }
        else if month != 2 {
            result = day <= 30 ? true : false
        }
        else {
            if year % 4 == 0 {
                result = day <= 29 ? true : false
            }
            else {
                result = day <= 28 ? true : false
            }
        }
        
        return result
    }
    
    // insert a user data row into database 
    func seedUserInfo() {
        let userEntity = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: moc)
        userEntity.setValue("", forKey: "name")
        userEntity.setValue("Not Set", forKey: "dateOfBirth")
        userEntity.setValue("Not Set", forKey: "height")
        userEntity.setValue("Not Set", forKey: "gender")
        do {
            try moc.save()
        } catch {
            fatalError("failure to save context: \(error)")
        }
    }
    
    // update the user info labels by using the data in DB
    func updateUserInfoLabels() {
        let userFetchReq = NSFetchRequest(entityName: "User")
        do {
            let fetchedUser = try moc.executeFetchRequest(userFetchReq) as! [User]
            let user = fetchedUser.first!
            nameTextField.text = user.name
            DOBtableViewCell.detailTextLabel?.text = user.dateOfBirth
            heightTableViewCell.detailTextLabel?.text = user.height
            genderTableViewCell.detailTextLabel?.text = user.gender
            print("there are \(fetchedUser.count) user(s) in the DB")
            
        }
        catch {
            fatalError("Error fetched user \(error)")
        }
    }
    
    // update the user info from labels to DB
    func updateUserInfoToDB() {
        let userFetchReq = NSFetchRequest(entityName: "User")
        do {
            let fetchedUser = try moc.executeFetchRequest(userFetchReq) as! [User]
            let user = fetchedUser.first!
            user.name = nameTextField.text
            user.dateOfBirth = DOBtableViewCell.detailTextLabel?.text
            user.height = heightTableViewCell.detailTextLabel?.text
            user.gender = genderTableViewCell.detailTextLabel?.text
            do {
                try moc.save()
            } catch {
                fatalError("failure to save context: \(error)")
            }
            
        }
        catch {
            fatalError("Error fetched user \(error)")
        }
    }
    
    // healthKit
    func healthDataTypesToWrite() -> Set<HKSampleType> {
        return NSSet.init(objects: FEVhealthType, FVChealthType) as! Set<HKSampleType>
    }
    
    func healthDataTypesToRead() -> Set<HKObjectType> {
        return NSSet.init(objects: FEVhealthType, FVChealthType) as! Set<HKSampleType>
    }
    
    func displayAlert(title: String, msg: String) -> Void {
        let alert = UIAlertController.init(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func askPermission() {
        // ask for Healthkit permission
        if HKHealthStore.isHealthDataAvailable() {
            let HKwriteDatatypes = healthDataTypesToWrite()
            let HKreadDatatypes = healthDataTypesToRead()
            
            healthStore.requestAuthorizationToShareTypes(HKwriteDatatypes, readTypes: HKreadDatatypes, completion: {(success , error ) -> Void in
                let generalMsg = "Some functionality may not be working properly. \n To grant data access, go to the built-in Health App, click \"Health Data\" -> \"Results\" -> \"Forced Expiratory Volume\"/\"Forced Vital Capacity\" -> \"Share Data\" -> \"Edit\" -> Enable both Share Data and Data Source."
                if !success {
                    let msg = "Error process request. " + generalMsg
                    self.displayAlert("Data Authentication", msg: msg)
                }
                self.checkPermission("FEV", healthType: self.FEVhealthType, generalMsg: generalMsg)
                self.checkPermission("FVC", healthType: self.FVChealthType, generalMsg: generalMsg)
                
            })
        }
    }
    
    // this function checks given health data type permission and
    // generate alert if data access permission denied.
    func checkPermission(typeStr: String, healthType: HKObjectType, generalMsg: String) {
        let permissionResult = self.healthStore.authorizationStatusForType(healthType)
        switch permissionResult {
        case HKAuthorizationStatus.SharingDenied:
            let msg = typeStr + " data authorization not (fully) granted. " + generalMsg
            self.displayAlert("Data Authentication", msg: msg)
        case HKAuthorizationStatus.SharingAuthorized:
            print(typeStr + " authorization granted")
        default:
            let msg = "Error process request. " + generalMsg
            self.displayAlert("Data Authentication", msg: msg)
        }
    }
    
    
    
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableView
     Cell {
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
