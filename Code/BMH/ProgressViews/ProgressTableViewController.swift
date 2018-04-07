//
//  ProgressTableViewController.swift
//  BMH
//
//  Created by Kalpesh Padia on 4/5/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import Charts

class ProgressTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChartViewDelegate {
    
    var showPickerView : Bool = false
    var showPieChart : Bool = true
    var showSlicedPieChart : Bool = false
    
    var activities : [ActEx]!
    var selectedActivity : Int = -1
    var dataArr : [Int] = []
    
    var selectionCellReuseIdentifer : String!
    var chartCellReuseIdentifier : String!
    var labelCellReuseIdentifer : String!
    
    let initDaysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let sliceColors = [UIColor(hex: "#1f77b4"), UIColor(hex: "#ff7f0e"), UIColor(hex: "#2ca02c"), UIColor(hex: "#d62728"), UIColor(hex: "#9467bd"), UIColor(hex: "#8c564b"), UIColor(hex: "#e377c2"), UIColor.lightGray]
    let chartColors = [UIColor(red: 18.0/255.0, green: 121.0/255.0, blue: 201.0/255.0, alpha: 1.0), UIColor.lightGray]
    
    var tap : UITapGestureRecognizer!
    
    var activityDebugLabel : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // load the activity list and register custom nibs depending on the scene
        activities = []
        if self.restorationIdentifier == "Progress_ActivityViewController" {
            activities = appDelegate.activities
            
            selectionCellReuseIdentifer = "Progress_ActivitySelectionCell"
            chartCellReuseIdentifier = "Progress_ActivityChartCell"
            labelCellReuseIdentifer = "Progress_ActivityViewCell" // must be the same identifier as that for the prototype cell in the Storyboard
            
            activityDebugLabel = "activity"
        }
        else if self.restorationIdentifier == "Progress_ExerciseViewController" {
            activities = appDelegate.exercises
            
            selectionCellReuseIdentifer = "Progress_ExerciseSelectionCell"
            chartCellReuseIdentifier = "Progress_ExerciseChartCell"
            labelCellReuseIdentifer = "Progress_ExerciseViewCell" // must be the same identifier as that for the prototype cell in the Storyboard
            
            activityDebugLabel = "exercise"
        }
        
        self.tableView.register(UINib(nibName:"SelectionTableViewCell", bundle: nil), forCellReuseIdentifier: selectionCellReuseIdentifer)
        self.tableView.register(UINib(nibName:"ProgressChartCell", bundle: nil), forCellReuseIdentifier: chartCellReuseIdentifier)
        
        // custom double tap gesture which is added and removed at will
        tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture))
        tap.numberOfTapsRequired = 2
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
        let chartCell =  ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))) as! ProgressChartCell)
        chartCell.pieChartView.clear()
        
        // get the data for the selected activity
        // Retrieve values for this week from Firebase
        
        // For now, create some dummy data
        createDummyData()
        
        // update the chart in third section first row
        createChart(inCell: chartCell, forActivity: selectedActivity)
        
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell = .init()
        if (indexPath.section == 0 && indexPath.row == 1) {
            cell = tableView.dequeueReusableCell(withIdentifier: selectionCellReuseIdentifer, for: indexPath)
            
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
        }
        else if (indexPath.section == 0 && indexPath.row == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: labelCellReuseIdentifer, for: indexPath)
            
            // Configure the cell...
            // Set the label either as a default value or based on what the user selected in picker.
            if  selectedActivity == -1 {
                cell.textLabel?.text = activities[0].name
            }
            else {
                cell.textLabel?.text = activities[selectedActivity].name
            }
        }
        else if (indexPath.section == 1){
            cell = tableView.dequeueReusableCell(withIdentifier: labelCellReuseIdentifer, for: indexPath)
            
            // Configure the cell...
            cell.textLabel?.text = weekDaysString()
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: chartCellReuseIdentifier, for: indexPath)
            
            // get the data for the selected activity
            // Retrieve values for this week from Firebase
            
            // For now, create some dummy data
            createDummyData()
            
            // create chart inside this cell
            if selectedActivity == -1 {
                createChart(inCell: cell as! ProgressChartCell, forActivity: 0)
            }
            else {
                createChart(inCell: cell as! ProgressChartCell, forActivity: selectedActivity)
            }
            
            // associate custom handler for touch up inside the toggle buttons in our chart cells
            (cell as! ProgressChartCell).pieChartToggle.addTarget(self, action: #selector(togglePieChartType(button:)), for: UIControlEvents.touchUpInside)
            (cell as! ProgressChartCell).barChartToggle.addTarget(self, action: #selector(toggleChartType(button:)), for: UIControlEvents.touchUpInside)
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
            return 455;
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
    
    // MARK: - Chart View Delegate
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog("chartValueSelected");
        
        // get the cell that contains the chartview
        let cell = (self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))) as! ProgressChartCell
        
        // get the value of the selected day
        let value = Int(entry.y)
        
        _ = updateProgressValue(value: value, inCell: cell)
        
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected");
        
        // get the cell that contains the chartview
        let cell = (self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))) as! ProgressChartCell
        
        _ = updateProgressValue(value: cell.progressValue, inCell: cell)
    }
    
    // MARK: - Custom functions
    func createDummyData() {
        if dataArr.count > 0 {
            dataArr.removeAll()
        }
        
        var limit : UInt32 = 3000
        if self.restorationIdentifier == "Progress_ExerciseViewController" {
            limit = 5
        }
        
        for _ in 0...6 {
            dataArr.append(Int(arc4random_uniform(limit)))
        }
    }
    
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
    
    func updateProgressValue(value: Int, inCell cell: ProgressChartCell) -> UIColor {
        let activity = cell.actEx
        // update the bottom view
        cell.iconImage.image = UIImage(named: (activity?.imageName)!)
        cell.iconLabel.text = activity?.name
        
        // calculate percent of goal achieved to customize label color
        var goalPercent = 0.0
        var valueColor = UIColor.orange
        
        goalPercent = Double(value) * 100.0 / Double((activity?.goalValue)!)
        
        // Customize label color
        if goalPercent <= 30.0 {
            valueColor = UIColor.red
        }
        else if goalPercent <= 80.0 {
            valueColor = UIColor.orange
        }
        else {
            valueColor = UIColor(hex: "#22AA03")
        }
        
        var valueAttribute = [NSAttributedStringKey.font: UIFont(name: "Hiragino Sans", size: 24.0)!, NSAttributedStringKey.foregroundColor: valueColor]
        let valueString = NSMutableAttributedString(string: String(value), attributes: valueAttribute)
        
        valueAttribute = [NSAttributedStringKey.font: UIFont(name: "Hiragino Sans", size: 20.0)!, NSAttributedStringKey.foregroundColor: valueColor]
        let valueString2 = NSAttributedString(string: " " + (activity?.goalUnits)!, attributes: valueAttribute)
        valueString.append(valueString2)
        cell.valueLabel.attributedText = valueString
        
        return valueColor
    }
    
    // Create a chart inside the specified cell
    func createChart(inCell cell: ProgressChartCell, forActivity index: Int) {
        // Configure the cell...
        // For this activity obtain weekly goal value and units
        let activity = activities[index]
        
        // save activity into cell for futture use
        cell.actEx = activity
        
        if showPieChart {
            // Create a pie chart
            drawPieChart(inCell: cell, withData: dataArr)
            
            // set chart delegate to self
            cell.pieChartView.delegate = self
            
            // custom double tap gesture if showing not showing slices
            if !showSlicedPieChart {
                cell.pieChartView.addGestureRecognizer(tap)
            } else {
                cell.pieChartView.removeGestureRecognizer(tap)
            }
        }
        else {
            // Create a bar chart
            drawBarChart(inCell: cell, withData: dataArr)
            
            // set chart delegate to self
            cell.barChartView.delegate = self
        }
        
    }
    
    // draw a pie chart
    func drawPieChart(inCell cell: ProgressChartCell, withData initValues: [Int]) {
        // get the activity object for this cell
        let activity = cell.actEx
        
        let chartView = cell.pieChartView!
        
        var values : [Int] = []
        var daysOfWeek : [String] = []
        var setColors : [UIColor] = []
        var sum = 0
        
        // calculate percent of goal achieved to customize label color
        for i in 0...6 {
            if (initValues[i] > 0) {
                sum += initValues[i]
                
                if showSlicedPieChart {
                    values.append(initValues[i])
                    daysOfWeek.append(initDaysOfWeek[i])
                    setColors.append(sliceColors[i])
                }
            }
        }
        
        // save the total progress this week
        cell.progressValue = sum
        
        // need to add a remaining part if not showing sliced pie chart
        if !showSlicedPieChart {
            values.append(sum)
            daysOfWeek.append("Completed")
            setColors.append(chartColors[0])
            
            // create an optional empty "gray area"
            if sum < (activity?.goalValue)! {
                values.append((activity?.goalValue)! - sum)
                daysOfWeek.append("Remaining")
                setColors.append(chartColors[1])
            }
        }
        
        // First customize the bottom view
        let valueColor = updateProgressValue(value: sum, inCell: cell)
        
        // create data entries
        let entries = (0..<values.count).map { (i) -> PieChartDataEntry in
            return PieChartDataEntry(value: Double(values[i]), label: daysOfWeek[i])
        }
        
        // create a data set from the data
        let set = PieChartDataSet(values: entries, label: "")
        
        // customize the data set
        set.drawIconsEnabled = false
        set.drawValuesEnabled = false // hides the value of each day
        set.colors = setColors
        set.sliceSpace = 2
        
        if !showSlicedPieChart {
            set.sliceSpace = 0
        }
        
        // customize the legend
        let legend = chartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.xEntrySpace = 7
        
        // customize the center text
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        var valueAttribute = [NSAttributedStringKey.font: UIFont(name: "Hiragino Sans", size: 36.0)!, NSAttributedStringKey.foregroundColor: valueColor, NSAttributedStringKey.paragraphStyle: paragraphStyle]
        
        let centerText = NSMutableAttributedString(string: String(sum) + "\n" + String((activity?.goalValue)!) + " " + (activity?.goalUnits)!)
        centerText.setAttributes(valueAttribute, range: NSRange(location: 0, length: centerText.length))
        
        valueAttribute = [NSAttributedStringKey.font: UIFont(name: "Hiragino Sans", size: 16.0)!, NSAttributedStringKey.foregroundColor: UIColor.black]
        centerText.addAttributes(valueAttribute, range: NSRange(location: String(sum).count, length: centerText.length - String(sum).count))
        
        // assign the center text
        chartView.centerAttributedText = centerText
        chartView.drawCenterTextEnabled = true
        
        // chartView properties
        chartView.chartDescription?.enabled = false
        
        // finally set the data
        let data = PieChartData(dataSet: set)
        
        // visualize
        chartView.data = data
        
        // and animate
        chartView.animate(xAxisDuration: 1.2, easingOption: .easeOutQuint)
    }
    
    // draw a bar chart
    func drawBarChart(inCell cell: ProgressChartCell, withData initValues: [Int]) {
        // get the activity object for this cell
        let activity = cell.actEx
        
        let chartView = cell.barChartView!
        let formatter:BarChartFormatter = BarChartFormatter()
        
        var values : [Int] = []
        var setColors : [UIColor] = []
        var sum = 0
        
        // calculate percent of goal achieved to customize label color
        for i in 0...6 {
            if (initValues[i] > 0) {
                sum += initValues[i]
                values.append(initValues[i])
                setColors.append(sliceColors[i])
            }
        }
        
        // save the total progress this week
        cell.progressValue = sum
        
        // customize the bottom view
        _ = updateProgressValue(value: sum, inCell: cell)
        
        // create data entries
        let entries = (0..<values.count).map { (i) -> BarChartDataEntry in
            _ = formatter.stringForValue(Double(i), axis: chartView.xAxis)
            return BarChartDataEntry(x: Double(i), y: Double(values[i]))
        }
        
        // create a data set from the data
        let datasetLabel : String = "Goal: " +  String((activity?.goalValue)!) + " " + (activity?.goalUnits)!
        let set = BarChartDataSet(values: entries, label: datasetLabel)
        
        // customize the data set
        set.drawIconsEnabled = false
        set.drawValuesEnabled = false //hides the day values
        set.colors = setColors
        
        // customize the axes
        chartView.rightAxis.enabled = false
        chartView.rightAxis.labelPosition = .outsideChart
        chartView.rightAxis.spaceTop = 0.01
        chartView.rightAxis.axisMinimum = 0
        
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelPosition = .outsideChart
        chartView.leftAxis.spaceTop = 0.01
        chartView.leftAxis.axisMinimum = 0
        
        chartView.xAxis.enabled = true
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelCount = values.count
        chartView.xAxis.valueFormatter = formatter
        
        // customize the legend
        let legend = chartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.drawInside = false
        legend.xEntrySpace = 0
        legend.form = .none
        legend.font = UIFont(name: "Hiragino Sans", size: 16.0)!
        legend.xOffset = -(datasetLabel.width(withConstrainedHeight: 16.0, font: legend.font))*0.3
        
        // chartView properties
        chartView.chartDescription?.enabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        
        // finally set the data
        let data = BarChartData(dataSet: set)
        
        // visualize
        chartView.data = data
        
        // and animate
        chartView.animate(yAxisDuration: 1.2, easingOption: .easeOutQuart)
    }
    
    // MARK: - Custom IBActions for controlling the chart type
    // toggle between filled and segmented pie chart
    @objc func togglePieChartType (button : UIButton) {
        // toggle the state of Pie Chart
        showSlicedPieChart = !showSlicedPieChart
        
        // start tableView updates
        self.tableView.beginUpdates()
        if (showSlicedPieChart) {
            // switch the image for the button
            button.setImage(UIImage(named: "donut-single"), for: UIControlState.normal)
            print ("Now showing donut-multi")
        }
        else {
            // switch the image for the button
            button.setImage(UIImage(named: "donut-multi"), for: UIControlState.normal)
            print ("Now showing donut-single")
        }
        
        // update the chart
        let cell = ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))) as! ProgressChartCell)
        
        if selectedActivity == -1 {
            cell.pieChartView.clear()
            createChart(inCell: cell, forActivity: 0)
        }
        else {
            cell.pieChartView.clear()
            createChart(inCell: cell, forActivity: selectedActivity)
        }
        
        // end tableView udpates
        self.tableView.endUpdates()
    }
    
    // toggle between pie chart and bar chart
    @objc func toggleChartType (button : UIButton) {
        let cell = ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))) as! ProgressChartCell)
        
        // toggle the state of Pie Chart
        showPieChart = !showPieChart
        
        // start tableView updates
        self.tableView.beginUpdates()
        if (showPieChart) {
            // switch the image for the button
            button.setImage(UIImage(named: "bar-chart"), for: UIControlState.normal)
            button.imageEdgeInsets = UIEdgeInsetsMake(4,4,4,4) // hack because we don't have padding for the bar chart icon
            print ("Now showing pie chart")
            
            // update the chartview visibility
            cell.pieChartView.isHidden = false
            cell.barChartView.isHidden = true
            cell.pieChartToggle.isHidden = false
        }
        else {
            // switch the image for the button
            if (showSlicedPieChart) {
                button.setImage(UIImage(named: "donut-multi"), for: UIControlState.normal)
            }
            else {
                button.setImage(UIImage(named: "donut-single"), for: UIControlState.normal)
            }
            button.imageEdgeInsets = UIEdgeInsetsMake(2,2,2,2)
            print ("Now showing bar chart")
            
            // update the chartview visibility
            cell.pieChartView.isHidden = true
            cell.barChartView.isHidden = false
            cell.pieChartToggle.isHidden = true
        }
        
        // draw new chart
        if selectedActivity == -1 {
            createChart(inCell: cell, forActivity: 0)
        }
        else {
            createChart(inCell: cell, forActivity: selectedActivity)
        }
        
        // end tableView udpates
        self.tableView.endUpdates()
    }
    
    // MARK: - Custom gestures for piechartview
    @objc func doubleTapGesture() {
        print ("double tap recognized")
        let cell = ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))) as! ProgressChartCell)
        if cell.pieChartView.highlighted[0].x == 0.0 {
            togglePieChartType(button: cell.pieChartToggle)
        }
    }
}
