//
//  Progress_ActivityViewController.swift
//  BMH
//
//  Created by Kalpesh Padia on 3/28/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit

class Progress_ActivityViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var showPickerView : Bool = false
    var activityList : [String] = ["Physical Therapy @ PT Clinic",
                                   "Physical Therapy @ Home Session",
                                   "Walking",
                                   "Running/Elliptical",
                                   "Swimming",
                                   "Strength Training",
                                   "Cycling/Hand Cycling",
                                   "Yoga/Pilates"]
    var selectedActivity : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // load the activity list array from a file?
        // for now we are hard-coding the list above
        
        // register our custom nibs
        self.tableView.register(UINib(nibName:"SelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "Progress_ActivitySelectionCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Picker view data source and delegates
    // number of sections
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // number of items
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activityList.count
    }
    
    // update the content shown in pickerview
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < activityList.count  {
            return activityList[row]
        }
        return ""
    }
    
    // if select any row, force update the table view
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tableView.beginUpdates()
        selectedActivity = activityList[row]
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SelectionTableViewCell).textField.text = selectedActivity
        self.tableView.endUpdates()
    }
    
    // MARK: - Table view data source
    
    // Return number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // Return number of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    // Return a dynamic cell depending on the section.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Progress_ActivitySelectionCell", for: indexPath) as! SelectionTableViewCell
            
            // Configure the cell...
            //cell.pickerView.isHidden = !self.showPickerView
            
            cell.pickerView.delegate = self
            cell.pickerView.dataSource = self
            
            // set the first row in pickerview as selected
            cell.pickerView.selectRow(0, inComponent: 0, animated: false)
            
            // and set the text to that
            selectedActivity = activityList[cell.pickerView.selectedRow(inComponent: 0)]
            cell.textField.text = selectedActivity
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Progress_ActivityViewCell", for: indexPath)
            
            // Configure the cell...
            
            return cell
        }
    }
    
    // Set the title for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Choose an Activity"
        case 1:
            return "Showing Week of:"
        default:
            return ""
        }
    }
    
    // Remember if a row was clicked on. Primarily needed so that we can toggle the height of row in section one.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.tableView.beginUpdates()
            self.showPickerView = !self.showPickerView
            self.tableView.endUpdates()
        }
    }
    
    // Set the height for a row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if self.showPickerView {
                return 186;
            }
            else {
                return 38;
            }
        }
        
        if indexPath.section == 1 {
            return 44;
        }
        
        if indexPath.section == 2 {
            return 200;
        }
        
        return 44;
    }
    
    
}
