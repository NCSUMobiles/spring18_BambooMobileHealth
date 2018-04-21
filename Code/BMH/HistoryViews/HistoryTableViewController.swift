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

class HistoryTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChartViewDelegate {
    
    var showPickerView : Bool = false
    var activities : [ActEx]!
    var selectedActivity : Int = -1

    var selectionCellReuseIdentifer : String!
    var chartCellReuseIdentifier : String!
    var labelCellReuseIdentifer : String!

    var activityDebugLabel : String = ""
    
    // declare dummy data for now
    var hoursLabel: [String]!
    var weekLabel: [String]!
    var monthLabel: [String]!
    var yearLabel: [String]!
    var stepsTaken = [Int]()
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    var selectedSegment = 1
    // mocking data for one year
    var yearData  = Array(repeating: Array(repeating: 0, count: 4), count: 12)
    var monthData = Array(repeating: Array(repeating: 0, count: 7), count: 4)
    var weekData =  Array(repeating: Array(repeating: 0, count: 24), count: 7)
    
    var dataLabel: [String]!
    var dataValue = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // load the activity list and register custom nibs depending on the scene
        activities = []
        hoursLabel = ["12A", "1A", "2A", "3A", "4A", "5A", "6A", "7A", "8A", "9A", "10A", "11A", "12P", "1P", "2P", "3P", "4P", "5P", "6P", "7P", "8P", "9P", "10P", "11P"]
        weekLabel = ["Mon", "Tue", "Wed", "Thr", "Fri", "Sat", "Sun"]
        monthLabel = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        yearLabel = ["2018"]
        
        
        if self.restorationIdentifier == "History_ActivityViewController" {
            activities = appDelegate.activities
            
            selectionCellReuseIdentifer = "History_ActivitySelectionCell"
            chartCellReuseIdentifier = "History_ActivityGraphView"
            labelCellReuseIdentifer = "History_ActivityViewCell" // must be the same identifier as that for the prototype cell in the Storyboard
            
            activityDebugLabel = "activity"
        }
        else if self.restorationIdentifier == "History_ExerciseViewController" {
            activities = appDelegate.exercises
            
            selectionCellReuseIdentifer = "History_ExerciseSelectionCell"
            chartCellReuseIdentifier = "History_ExerciseGraphView"
            labelCellReuseIdentifer = "History_ExerciseViewCell" // must be the same identifier as that for the prototype cell in the Storyboard
            
            activityDebugLabel = "exercise"
        }
        
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
        if selectedSegment == 2 {
            createChart(inCell: chartCell, forActivity: selectedActivity, withData: weekLabel, withData: createWeeklyData())
        }
        else if selectedSegment == 3 {
            createChart(inCell: chartCell, forActivity: selectedActivity, withData: monthLabel, withData: [Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000)])
        }
        else if selectedSegment == 4 {
            createChart(inCell: chartCell, forActivity: selectedActivity, withData: yearLabel, withData: [Int(20001)+107000])
        }
        else {
            createChart(inCell: chartCell, forActivity: selectedActivity, withData: hoursLabel, withData: createDailyData())
        }
        //createChart(inCell: chartCell, forActivity: selectedActivity, withData: hoursLabel, withData: createDailyData())
//        createChart(inCell: chartCell, forActivity: selectedActivity)
//        setChart(inCell: chartCell, forActivity: selectedActivity)
        self.tableView.endUpdates()
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
            
            cell.aggSwitch.addTarget(self, action: #selector(changeChart(sender:)), for: UIControlEvents.primaryActionTriggered)
            cell.aggSwitch.addTarget(self, action: #selector(updateChart(sender:)), for: .valueChanged)
            
            if selectedActivity == -1 {
                if selectedSegment == 2 {
                    createChart(inCell: cell, forActivity: 0, withData: weekLabel, withData: createWeeklyData())
                }
                else if selectedSegment == 3 {
                    createChart(inCell: cell, forActivity: 0, withData: monthLabel, withData: [Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000)])
                }
                else if selectedSegment == 4 {
                    createChart(inCell: cell, forActivity: 0, withData: yearLabel, withData: [Int(20001)+107000])
                }
                else {
                    createChart(inCell: cell, forActivity: 0, withData: hoursLabel, withData: createDailyData())
                }
                
//                setChart(inCell: cell, forActivity: 0)
            }
            else {
                if selectedSegment == 2 {
                    createChart(inCell: cell, forActivity: 0, withData: weekLabel, withData: createWeeklyData())
                }
                else if selectedSegment == 3 {
                    createChart(inCell: cell, forActivity: 0, withData: monthLabel, withData: [Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000), Int(arc4random_uniform(1001)+7000)])
                }
                else if selectedSegment == 4 {
                    createChart(inCell: cell, forActivity: 0, withData: yearLabel, withData: [Int(20001)+107000])
                }
                else {
                    createChart(inCell: cell, forActivity: 0, withData: hoursLabel, withData: createDailyData())
                }
//                setChart(inCell: cell, forActivity: selectedActivity)
            }
            
            return cell
        }
    }
    
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
            return 500;
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
//        if section == 0 {
//            return 2
//        }
        return tableView.sectionFooterHeight
    }
    
    var selectIndex : Int = 0 {
        didSet{
            // use stepperValue with your UIButton as you want
        }
    }
    
    @IBAction func changeChart(sender: UISegmentedControl) {
//        print ("self: ", self.restorationIdentifier!)
//        print ("index: ", sender.selectedSegmentIndex)
        selectIndex = Int(sender.selectedSegmentIndex)
//        print("selectIndex is: ", selectIndex)
        
    }

    // MARK: - Custom functions
    
    
    // Create a chart
    /*
    func createChart(inCell cell: HistoryCell, forActivity index: Int) {
        cell.barChartView.noDataText = "You need to provide data for the chart."
        // Configure the cell...
        // For this activity obtain weekly goal value and units
        let activity = activities[index]
        
        // save activity into cell for futture use
        cell.actEx = activity
        
        // Retrieve values for this week from Firebase
        
        // Update the chart to show the updated value
        
        // Set a dummy donut chart
        setChart(inCell: cell, forActivity: )
        
    }
    */
    
    // generate daily mocking data
    func createDailyData()-> Array<Int> {
        return [Int(arc4random_uniform(21)), Int(arc4random_uniform(21)), Int(arc4random_uniform(21)), Int(arc4random_uniform(21)), Int(arc4random_uniform(21)), Int(arc4random_uniform(21)), Int(arc4random_uniform(21)), Int(arc4random_uniform(31)),
            Int(arc4random_uniform(501)), Int(arc4random_uniform(501)), Int(arc4random_uniform(501)), Int(arc4random_uniform(301)),
            Int(arc4random_uniform(301)), Int(arc4random_uniform(501)), Int(arc4random_uniform(401)), Int(arc4random_uniform(401)),
            Int(arc4random_uniform(301)), Int(arc4random_uniform(301)), Int(arc4random_uniform(501)), Int(arc4random_uniform(501)),
            Int(arc4random_uniform(401)), Int(arc4random_uniform(301)), Int(arc4random_uniform(401)), Int(arc4random_uniform(301))]
    }
    
    // generate weekly mocking data
    func createWeeklyData()-> Array<Int> {
        for i in 0..<7 {
            weekData[i] = createDailyData()
        }
        var oneWeekData = [Int]()
        for i in 0..<weekData.count {
            oneWeekData.append(weekData[i].reduce(0){$0 + $1})
        }
        
        return oneWeekData
    }
    
    // generate monthly mocking data
    func createMonthlyData()-> Array<Int> {
        for i in 0..<4 {
            monthData[i] = createWeeklyData()
        }
        var oneMonthData = [Int]()
        for i in 0..<monthData.count {
            oneMonthData.append(monthData[i].reduce(0){$0 + $1})
        }
        return oneMonthData
    }
    
    // generate yearly mocking data
    func createYearlyData()-> Array<Int> {
        for i in 0..<12 {
            yearData[i] = createMonthlyData()
        }
        var oneYearData = [Int]()
        for i in 0..<yearData.count {
            oneYearData.append(yearData[i].reduce(0){$0 + $1})
        }
        return oneYearData
    }
    
    @objc func updateChart(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            selectedSegment = 1
        }
        else if sender.selectedSegmentIndex == 1 {
            selectedSegment = 2
        }
        else if sender.selectedSegmentIndex == 2 {
            selectedSegment = 3
        }
        else {
            selectedSegment = 4
        }
        self.tableView.reloadData()
    }
    
    func createChart(inCell cell: HistoryCell, forActivity index: Int, withData x: [String], withData y: [Int]) {
        let activity = activities[index]
        cell.actEx = activity
        
        
        // drawChart
        drawChart(inCell: cell, withData: x, withData: y)
        
        cell.barChartView.delegate = self
    }
    
//    func createChart(inCell cell: HistoryCell, forActivity index: Int) {
//        let activity = activities[index]
//        cell.actEx = activity
//
//
//        // drawChart
//        drawChart(inCell: cell, withData: hoursLabel, withData: createDailyData())
//        cell.barChartView.delegate = self
//    }
    
    func drawChart(inCell cell: HistoryCell, withData data_Label: [String], withData data_Value: [Int]) {
        var dataLabel_: [String]!
        var dataValue_ = [Int]()
        
        dataLabel_ = data_Label
        dataValue_ = data_Value
        
        var sum = 0
        var dataEntries:[BarChartDataEntry] = []
        let activity = cell.actEx
        
        let chartView = cell.barChartView!
        let d_formatter: DayFormatter = DayFormatter()
        let w_formatter: WeekFormatter = WeekFormatter()
        let m_formatter: MonthFormatter = MonthFormatter()
        let y_formatter: YearFormatter = YearFormatter()
        
        axisFormatDelegate = self as IAxisValueFormatter
        
        
      
        
        for i in 0..<dataLabel_.count{
//            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(dataValue_[i]) , data: dataLabel_ as AnyObject?)
            sum += dataValue_[i]
//            dataValue_.append(dataValue[i])
           
            //            print(dataEntry)
//            dataEntries.append(dataEntry)
        }
        
        // default set selectedSegment as 1 before user click other seg
        dataEntries = (0..<dataValue_.count).map { (i) -> BarChartDataEntry in
            _ = d_formatter.stringForValue(Double(i), axis: chartView.xAxis)
            return BarChartDataEntry(x: Double(i), y: Double(dataValue_[i]))
        }
        
        print("Before select", dataEntries)
        if selectedSegment == 1 {
            dataEntries = (0..<dataValue_.count).map { (i) -> BarChartDataEntry in
                _ = d_formatter.stringForValue(Double(i), axis: chartView.xAxis)
                return BarChartDataEntry(x: Double(i), y: Double(dataValue_[i]))
            }
            print("After", dataEntries)
        } else if selectedSegment == 2 {
            dataEntries = (0..<dataValue_.count).map { (i) -> BarChartDataEntry in
                _ = w_formatter.stringForValue(Double(i), axis: chartView.xAxis)
                return BarChartDataEntry(x: Double(i), y: Double(dataValue_[i]))
            }
        } else if selectedSegment == 3 {
            dataEntries = (0..<dataValue_.count).map { (i) -> BarChartDataEntry in
                _ = m_formatter.stringForValue(Double(i), axis: chartView.xAxis)
                return BarChartDataEntry(x: Double(i), y: Double(dataValue_[i]))
            }
        } else {
            dataEntries = (0..<dataValue_.count).map { (i) -> BarChartDataEntry in
                _ = y_formatter.stringForValue(Double(i), axis: chartView.xAxis)
                return BarChartDataEntry(x: Double(i), y: Double(dataValue_[i]))
            }
        }
        
        
        let xAxisValue = cell.barChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        xAxisValue.labelPosition = .bottom
        xAxisValue.granularityEnabled = true
        xAxisValue.drawGridLinesEnabled = false
        xAxisValue.labelCount = 24
        xAxisValue.granularity = 1
        xAxisValue.drawLabelsEnabled = true
        xAxisValue.drawLimitLinesBehindDataEnabled = true
        xAxisValue.avoidFirstLastClippingEnabled = false
        
        print("Unit is: ", (activity?.goalUnits)!)
        var labelString = (activity?.goalUnits)! + " Count"
        //        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Steps Count")
        let chartDataSet = BarChartDataSet(values: dataEntries, label: labelString)
        
        
        
        chartDataSet.colors = [UIColor(hex: "#7000ff")]
        
        // update the sumValue, unit, bottomLabel
        cell.valueLabel.text = String(sum)
        //        cell.unitsLabel
        
        // finally set the data
        let chartData = BarChartData(dataSet: chartDataSet)
        
        // visualize
        cell.barChartView.data = chartData
        
        // save the total steps
        cell.sumValue = sum
        
        // display the unit
        cell.unitsLabel.text = (activity?.goalUnits)!
        
        
    }
    
    // func setChart(inCell cell: HistoryCell, dataEntryX forX:[String],dataEntryY forY: [Int]) {
    func setChart(inCell cell: HistoryCell, forActivity index: Int) {

        let valueColor = UIColor.blue
        let activity = activities[index]
        cell.actEx = activity
        
//        cell.aggSwitch.addTarget(self, action: "updateChart:", for:.valueChanged)
        // mocking dataLabel
//        hoursLabel = ["12A", "1A", "2A", "3A", "4A", "5A", "6A", "7A", "8A", "9A", "10A", "11A", "12P", "1P", "2P", "3P", "4P", "5P", "6P", "7P", "8P", "9P", "10P", "11P"]
//        weekLabel = ["Mon", "Tue", "Wed", "Thr", "Fri", "Sat", "Sun"]
//        monthLabel = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//        yearLabel = ["2018"]
        
        
        // TODO: pass dataset as a parameter
//
//        for i in 0..<7 {
//            weekData[i] = createDailyData()
//        }
////        print("Week data", weekData)
        
//        var oneWeekData = [Int]()
//        for i in 0..<weekData.count {
//           oneWeekData.append(weekData[i].reduce(0){$0 + $1})
//        }
//        print(oneWeekData)
        
//        var dataLabel: [String]!
//        var dataValue = [Int]()
        
        if cell.aggSwitch.selectedSegmentIndex == 0 {
            print("In the index 0")
            dataLabel = hoursLabel
            // currently select first day of the week
            dataValue = weekData[0]
            
        }
        else if cell.aggSwitch.selectedSegmentIndex == 1 {
            print("In the index 1")
            dataLabel = weekLabel
          
//            dataValue = oneWeekData
//            dataValue = monthData[0]
        }
        else if cell.aggSwitch.selectedSegmentIndex == 2 {
            print("In the index 2")
            dataLabel = monthLabel
        }
        else if cell.aggSwitch.selectedSegmentIndex == 3 {
            print("In the index 3")
            dataLabel = yearLabel
        }
        
        axisFormatDelegate = self as IAxisValueFormatter
      
        
        var sum = 0
//        stepsTaken = [Int(arc4random_uniform(7001)), Int(arc4random_uniform(7001)), Int(arc4random_uniform(7001)), Int(arc4random_uniform(7001)), Int(arc4random_uniform(7001)), Int(arc4random_uniform(7001)), Int(arc4random_uniform(7001))]
        
        var dataEntries:[BarChartDataEntry] = []
        
        for i in 0..<dataLabel.count{
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(dataValue[i]) , data: dataLabel as AnyObject?)
            sum += dataValue[i]
//            print(dataEntry)
            dataEntries.append(dataEntry)
        }
        var labelString = activity.goalUnits + " Count"
//        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Steps Count")
        let chartDataSet = BarChartDataSet(values: dataEntries, label: labelString)
        
        let xAxisValue = cell.barChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        chartDataSet.colors = [UIColor(hex: "#7000ff")]
        
        // update the sumValue, unit, bottomLabel
        cell.valueLabel.text = String(sum)
//        cell.unitsLabel
        
        // finally set the data
        let chartData = BarChartData(dataSet: chartDataSet)
        
        // visualize
        cell.barChartView.data = chartData
        
        // save the total steps
        cell.sumValue = sum
        
        // display the unit
        cell.unitsLabel.text = (activity.goalUnits)
        
        
        
    }
}

extension HistoryTableViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var hoursLabel: [String]!
        var weekLabel: [String]!
        var monthLabel: [String]!
        var yearLabel: [String]!
        
        hoursLabel = ["12A", "1A", "2A", "3A", "4A", "5A", "6A", "7A", "8A", "9A", "10A", "11A", "12P", "1P", "2P", "3P", "4P", "5P", "6P", "7P", "8P", "9P", "10P", "11P"]
        weekLabel = ["Mon", "Tue", "Wed", "Thr", "Fri", "Sat", "Sun"]
        monthLabel = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        yearLabel = ["2018"]
        
        if selectedSegment == 1 {
            print("select 1")
            return hoursLabel[Int(value)]
        }
        else if selectedSegment == 2 {
            print("select 2")
             return weekLabel[Int(value)]
        }
        else if selectedSegment == 3 {
            print("select 3")
             return monthLabel[Int(value)]
        }
        else if selectedSegment == 4 {
            return yearLabel[Int(value)]
        }
        else {
            print("default")
             return hoursLabel[Int(value)]
            
        }
        
    }
}
