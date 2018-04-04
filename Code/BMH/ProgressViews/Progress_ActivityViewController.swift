//
//  Progress_ActivityViewController.swift
//  BMH
//
//  Created by Kalpesh Padia on 3/28/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import Charts

class Progress_ActivityViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var showPickerView : Bool = false
    var activityList : [String]!
    var selectedActivity : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // register our custom nibs
        self.tableView.register(UINib(nibName:"SelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "Progress_ActivitySelectionCell")
        self.tableView.register(UINib(nibName:"ProgressChartCell", bundle: nil), forCellReuseIdentifier: "Progress_ActivityChartCell")
        
        // load the activity list
        activityList = []
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        for activity in appDelegate.activities {
            activityList.append(activity.name)
        }
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
        print("Selected activity \"\(selectedActivity)\"")
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)))?.textLabel?.text = selectedActivity
        self.tableView.endUpdates()
    }
    
    // MARK: - Table view data source and delegates
    
    // Return number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // Return number of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.showPickerView && section == 0 {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == 0 && indexPath.row == 1) {
            cell.layoutSubviews()
        }
    }
    
    // Return a dynamic cell depending on the section.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell = .init()
        if (indexPath.section == 0 && indexPath.row == 1) {
            cell = tableView.dequeueReusableCell(withIdentifier: "Progress_ActivitySelectionCell", for: indexPath)
            
            // Configure the cell...
            let pickerView = (cell as! SelectionTableViewCell).pickerView
            pickerView?.delegate = self
            pickerView?.dataSource = self
            pickerView?.showsSelectionIndicator = true;
            
            // save the selected text
            if selectedActivity == "" {
                // scroll to the middle activity
                pickerView?.selectRow(activityList.count / 2, inComponent: 0, animated: true)
                
                // hack to make sure the selection indicator shows
                // first remove the picker
                pickerView?.removeFromSuperview()
                // then add it back
                cell.contentView.addSubview(pickerView!)
                // and finally set the constraints to make sure it fits horizontally centered
                cell.contentView.addConstraints([NSLayoutConstraint.init(item: pickerView as Any, attribute: .centerY, relatedBy: .equal, toItem: cell.contentView, attribute: .centerY, multiplier: 1, constant: 0),
                                                 NSLayoutConstraint.init(item: pickerView as Any, attribute: .trailing, relatedBy: .equal, toItem: cell.contentView, attribute: .trailing, multiplier: 1, constant: 0),
                                                 NSLayoutConstraint.init(item: pickerView as Any, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1, constant: 0)])
            }
            
            selectedActivity = activityList[(pickerView?.selectedRow(inComponent: 0))!]
            print("Selected activity \"\(selectedActivity)\"")
        }
        else if (indexPath.section == 0 && indexPath.row == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "Progress_ActivityViewCell", for: indexPath)
            
            // Configure the cell...
            // Set the label either as a default value or based on what the user selected in picker.
            if  selectedActivity == "" {
                cell.textLabel?.text = activityList[activityList.count / 2]
            } else {
                cell.textLabel?.text = selectedActivity
            }
        }
        else if (indexPath.section == 1){
            cell = tableView.dequeueReusableCell(withIdentifier: "Progress_ActivityViewCell", for: indexPath)
            
            // Configure the cell...
            cell.textLabel?.text = weekDaysString()
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "Progress_ActivityChartCell", for: indexPath)
            
            // Configure the cell...
            // For this activity retrieve weekly goal value and units from the local database
            // some default assumption
            let goalValue = 20000
            let goalUnits = "Steps"
            
            // Set a default donut chart where no goal is achieved
            createChart(forActivity: selectedActivity, inCell: (cell as! ProgressChartCell), withData: [0, 0, 0, 0, 0, 0, 0, goalValue], goalValue: goalValue, goalUnits: goalUnits)
            // Retrieve values for this week from Firebase
            
            // Update the chart to show the updated value 
        }
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
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
    
    // Remember if a row was clicked on, and then toggle the display of second row in first section
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.tableView.beginUpdates()
            self.showPickerView = !self.showPickerView
            if self.showPickerView {
                self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .top)
            }
            else {
                self.tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .top)
            }
            self.tableView.endUpdates()
        }
    }
    
    // Set the height for a row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1{
            return 163;
        }
        
        if indexPath.section == 1 {
            return 44;
        }
        
        // so that you can scroll and fill the screen in iPhone 5
        if indexPath.section == 2 {
            return 480;
        }
        
        return 44;
    }
    
    // Set the section header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return CGFloat.leastNormalMagnitude
        }
        return tableView.sectionHeaderHeight
    }
    // Set the section footer height
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 2
        }
        return tableView.sectionFooterHeight
    }
    
    // MARK: - Custom functions
    func weekDaysString() -> String {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))
        
        let startOfWeek = gregorian.date(byAdding: .day, value: 1, to: sunday!)
        let endOfWeek = gregorian.date(byAdding: .day, value: 7, to: sunday!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: startOfWeek!) + " — " + dateFormatter.string(from: endOfWeek!)
    }
    
    func createChart(forActivity activity: String, inCell cell: ProgressChartCell, withData values: [Int], goalValue: Int, goalUnits: String) {
        // customize the legend
        //cell.activityImage = [UIima]
    }
    
}
