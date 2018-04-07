//
//  HistoryTableViewController.swift
//  BMH
//
//  Created by Yu-Ching Hu on 3/29/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import Charts
import CoreMotion

class HistoryTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var showPickerView : Bool = false
    var activities : [ActEx]!
    var selectedActivity : Int = -1

    var selectionCellReuseIdentifer : String!
    var chartCellReuseIdentifier : String!
    var labelCellReuseIdentifer : String!
    
//    var activityList : [String] = ["Physical Therapy @ PT Clinic",
//                                   "Physical Therapy @ Home Session",
//                                   "Walking",
//                                   "Running/Elliptical",
//                                   "Swimming",
//                                   "Strength Training",
//                                   "Cycling/Hand Cycling",
//                                   "Yoga/Pilates"]
   
    
    var activityDebugLabel : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // load the activity list and register custom nibs depending on the scene
        activities = []
        
        if self.restorationIdentifier == "History_ActivityViewController" {
            activities = appDelegate.activities
            
            selectionCellReuseIdentifer = "History_ActivitySelectionCell"
            chartCellReuseIdentifier = "HistoryGraphView"
            labelCellReuseIdentifer = "History_ActivityViewCell" // must be the same identifier as that for the prototype cell in the Storyboard
            
            activityDebugLabel = "activity"
        }/*
        else if self.restorationIdentifier == "History_ExerciseViewController" {
            activities = appDelegate.exercises
            
            selectionCellReuseIdentifer = "History_ExerciseSelectionCell"
            chartCellReuseIdentifier = "HistoryGraphView"
            labelCellReuseIdentifer = "History_ExerciseViewCell" // must be the same identifier as that for the prototype cell in the Storyboard
            
            activityDebugLabel = "exercise"
        }*/
        
        self.tableView.register(UINib(nibName:"HistoryCell", bundle: nil), forCellReuseIdentifier: chartCellReuseIdentifier)
        self.tableView.register(UINib(nibName:"SelectionTableViewCell", bundle: nil), forCellReuseIdentifier: selectionCellReuseIdentifer)
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        return activities.count
    }
    
    // size the text in each row of pickerview
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let labelRow = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        
        pickerLabel.textColor = UIColor.black
        pickerLabel.text = activities[row].name
        pickerLabel.font = labelRow?.textLabel?.font
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    // if select any row, force update the table view
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tableView.beginUpdates()
        
        selectedActivity = row
        print("Selected \(activityDebugLabel) \"\(activities[selectedActivity].name)\"")
        
        // update the text in first section first row
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)))?.textLabel?.text = activities[selectedActivity].name
        
        // remove any existing selection
        let chartCell =  ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))) as! HistoryCell)
        chartCell.barChartView.clear()
    
        // update the chart in third section first row
        // TODO: change to random data
//        setChart(inCell: chartCell, dataEntryX: weekdays, dataEntryY: stepsTaken)
        setChart(inCell: chartCell, forActivity: selectedActivity)
        self.tableView.endUpdates()
    }
 
  
    // dummy data for now
    var weekdays: [String]!
    var stepsTaken = [Int]()
    weak var axisFormatDelegate: IAxisValueFormatter?
    
//    func setChart(inCell cell: HistoryCell, dataEntryX forX:[String],dataEntryY forY: [Int]) {
    func setChart(inCell cell: HistoryCell, forActivity index: Int) {
        cell.barChartView.noDataText = "You need to provide data for the chart."
        
        let activity = activities[index]
        
        axisFormatDelegate = self as IAxisValueFormatter
        weekdays = ["Mon", "Tue", "Wed", "Thr", "Fri", "Sat", "Sun"]
        stepsTaken = [Int(arc4random_uniform(7001)), Int(arc4random_uniform(7001)), Int(arc4random_uniform(7001)), Int(arc4random_uniform(7001)), Int(arc4random_uniform(7001)), Int(arc4random_uniform(7001)), Int(arc4random_uniform(7001))]
        
        var dataEntries:[BarChartDataEntry] = []
        
        for i in 0..<weekdays.count{
            // print(forX[i])
            // let dataEntry = BarChartDataEntry(x: (forX[i] as NSString).doubleValue, y: Double(unitsSold[i]))
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(stepsTaken[i]) , data: weekdays as AnyObject?)
            print(dataEntry)
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Steps Count")
        let chartData = BarChartData(dataSet: chartDataSet)
        cell.barChartView.data = chartData
        let xAxisValue = cell.barChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        
    }
    
    // MARK: - Table view data source

    // Return number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0 && indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: selectionCellReuseIdentifer, for: indexPath)
            
            // Configure the cell...
            let pickerView = (cell as! SelectionTableViewCell).pickerView
            pickerView?.delegate = self
            pickerView?.dataSource = self
            pickerView?.showsSelectionIndicator = true;
            
            // save the selected text
            if selectedActivity == -1 {
            
                // scroll to the middle activity
                pickerView?.selectRow(0, inComponent: 0, animated: true)
                
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
            
            selectedActivity = (pickerView?.selectedRow(inComponent: 0))!
            print("Selected \(activityDebugLabel) \"\(activities[selectedActivity].name)\"")
            return cell
        } else if (indexPath.section == 0 && indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: labelCellReuseIdentifer, for: indexPath)
            
            // Configure the cell...
            // Set the label either as a default value or based on what the user selected in picker.
            if  selectedActivity == -1 {
                cell.textLabel?.text = activities[0].name
            }
            else {
                cell.textLabel?.text = activities[selectedActivity].name
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: chartCellReuseIdentifier, for: indexPath) as! HistoryCell
            //(cell.barChartView).noDataText = "You need to provide data for the chart."
            cell.barChartView.maxVisibleCount = 10000
            cell.barChartView.chartDescription?.text = ""
           
            if selectedActivity == -1 {
                setChart(inCell: cell, forActivity: 0)
            }
            else {
                setChart(inCell: cell, forActivity: selectedActivity)
            }
            
            
            // create some dummy data
//            axisFormatDelegate = self as IAxisValueFormatter
//            weekdays = ["Mon", "Tue", "Wed", "Thr", "Fri", "Sat", "Sun"]
//            stepsTaken = [1733, 5896, 1617, 628, 4802, 3042, 5268]
            
            // load that dummy data into our cell
//            setChart(inCell: cell, dataEntryX: weekdays, dataEntryY: stepsTaken)
            return cell
        }
        
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryGraphView", for: indexPath) as! HistoryCell
//        (cell.barChartView).noDataText = "You need to provide data for the chart."
//        (cell.barChartView).maxVisibleCount = 10000
//        // create some dummy data
//        axisFormatDelegate = self as IAxisValueFormatter
//        weekdays = ["Mon", "Tue", "Wed", "Thr", "Fri", "Sat", "Sun"]
//        stepsTaken = [1733, 5896, 1617, 628, 4802, 3042, 5268]
//
//        // load that dummy data into our cell
//        setChart(inCell: cell, dataEntryX: weekdays, dataEntryY: stepsTaken)
//        return cell
        
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryGraphView", for: indexPath) as! HistoryCell
//        (cell.barChartView).noDataText = "You need to provide data for the chart."
//        (cell.barChartView).drawGridBackgroundEnabled = true
//        (cell.barChartView).maxVisibleCount = 10000
        
        // Configure the cell...
        
        /*
        // create some dummy data
        axisFormatDelegate = self as IAxisValueFormatter
        weekdays = ["Mon", "Tue", "Wed", "Thr", "Fri", "Sat", "Sun"]
        stepsTaken = [1733, 5896, 1617, 628, 4802, 3042, 5268]
        
        // load that dummy data into our cell
        setChart(inCell: cell, dataEntryX: weekdays, dataEntryY: stepsTaken)
        */
//        return cell
        
    }
    
/*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 490
    }
*/
    
    // Set the title for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Choose an Activity"
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
            return 455;
        }
    
        return 44;
    }
    
    // Set the section header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return CGFloat.leastNormalMagnitude
        }
        return tableView.sectionHeaderHeight
    }
    
    // Set the section footer height
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 2
        }
        return tableView.sectionFooterHeight
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HistoryTableViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return weekdays[Int(value)]
    }
}
