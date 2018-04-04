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

class History_ActivityViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    

    var weekdays: [String]!
    var stepsTaken = [Int]()
    weak var axisFormatDelegate: IAxisValueFormatter?
    
override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName:"HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryGraphView")
        
        /*
        axisFormatDelegate = self as IAxisValueFormatter
        weekdays = ["Mon", "Tue", "Wed", "Thr", "Fri", "Sat", "Sun"]
        stepsTaken = [1733, 5896, 1617, 628, 4802, 3042, 5268]
        setChart(dataEntryX: weekdays, dataEntryY: stepsTaken)
        */
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // register our custom nibs
        
    }

    func setChart(inCell cell: HistoryCell, dataEntryX forX:[String],dataEntryY forY: [Int]) {
        cell.barChartView.noDataText = "You need to provide data for the chart."
        var dataEntries:[BarChartDataEntry] = []
        for i in 0..<forX.count{
            // print(forX[i])
            // let dataEntry = BarChartDataEntry(x: (forX[i] as NSString).doubleValue, y: Double(unitsSold[i]))
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(forY[i]) , data: weekdays as AnyObject?)
            print(dataEntry)
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Steps Count")
        let chartData = BarChartData(dataSet: chartDataSet)
        cell.barChartView.data = chartData
        let xAxisValue = cell.barChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
//        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.showPickerView && section == 0 {
            return 2
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryGraphView", for: indexPath) as! HistoryCell
            (cell.barChartView).noDataText = "You need to provide data for the chart."
            (cell.barChartView).maxVisibleCount = 10000
            // create some dummy data
            axisFormatDelegate = self as IAxisValueFormatter
            weekdays = ["Mon", "Tue", "Wed", "Thr", "Fri", "Sat", "Sun"]
            stepsTaken = [1733, 5896, 1617, 628, 4802, 3042, 5268]
            
            // load that dummy data into our cell
            setChart(inCell: cell, dataEntryX: weekdays, dataEntryY: stepsTaken)
            return cell
        
        
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 490
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

extension History_ActivityViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return weekdays[Int(value)]
    }
}
