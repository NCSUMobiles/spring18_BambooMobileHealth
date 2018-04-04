//
//  Progress_ActivityViewController.swift
//  BMH
//
//  Created by Kalpesh Padia on 3/28/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import Charts

class Progress_ActivityViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChartViewDelegate {
    
    var showPickerView : Bool = false
    var activityList : [String]!
    var selectedActivity : Int = -1
    
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
        
        selectedActivity = row
        print("Selected activity \"\(activityList[selectedActivity])\"")
        
        // update the text in first section first row
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)))?.textLabel?.text = activityList[selectedActivity]
        
        // update the chart in third section first row
        createChart(inCell: ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))) as! ProgressChartCell), forActivity: selectedActivity)
        
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
            cell = tableView.dequeueReusableCell(withIdentifier: "Progress_ActivitySelectionCell", for: indexPath)
            
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
            print("Selected activity \"\(activityList[selectedActivity])\"")
        }
        else if (indexPath.section == 0 && indexPath.row == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "Progress_ActivityViewCell", for: indexPath)
            
            // Configure the cell...
            // Set the label either as a default value or based on what the user selected in picker.
            if  selectedActivity == -1 {
                cell.textLabel?.text = activityList[0]
            }
            else {
                cell.textLabel?.text = activityList[selectedActivity]
            }
        }
        else if (indexPath.section == 1){
            cell = tableView.dequeueReusableCell(withIdentifier: "Progress_ActivityViewCell", for: indexPath)
            
            // Configure the cell...
            cell.textLabel?.text = weekDaysString()
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "Progress_ActivityChartCell", for: indexPath)
            
            // create chart inside this cell
            if selectedActivity == -1 {
                createChart(inCell: cell as! ProgressChartCell, forActivity: 0)
            }
            else {
                createChart(inCell: cell as! ProgressChartCell, forActivity: selectedActivity)
            }
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
        let activity = (UIApplication.shared.delegate as! AppDelegate).activities[index]

        // save activity into cell for futture use
        cell.actEx = activity
        
        // Retrieve values for this week from Firebase
        
        // Update the chart to show the updated value
        // Set a dummy donut chart
        drawChart(inCell: cell, withData: [Int(arc4random_uniform(3001)), Int(arc4random_uniform(3001)), Int(arc4random_uniform(3001)), Int(arc4random_uniform(3001)), Int(arc4random_uniform(3001)), Int(arc4random_uniform(3001)), Int(arc4random_uniform(3001))])
        
        // set chart delegate to self
        cell.chartView.delegate = self
    }
    
    // draw the chart
    func drawChart(inCell cell: ProgressChartCell, withData initValues: [Int]) {
        let initDaysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        
        var values : [Int] = []
        var daysOfWeek : [String] = []
        // calculate percent of goal achieved to customize label color
        var sum = 0
        for i in 0...6 {
            if (initValues[i] > 0) {
                sum += initValues[i]
                
                values.append(initValues[i])
                daysOfWeek.append(initDaysOfWeek[i])
            }
        }
        
        // save the total progress this week
        cell.progressValue = sum
        let activity = cell.actEx
        
        // customize the bottom view
        let valueColor = updateProgressValue(value: sum, inCell: cell)
        
        // customize the legend
        let legend = cell.chartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.xEntrySpace = 7
        cell.chartView.chartDescription?.enabled = false
        
        // create data entries
        let entries = (0..<values.count).map { (i) -> PieChartDataEntry in
            return PieChartDataEntry(value: Double(values[i]), label: daysOfWeek[i])
        }
        
        // create a data set from the data
        let set = PieChartDataSet(values: entries, label: "")
        
        // customize the data set
        set.drawIconsEnabled = false
        set.drawValuesEnabled = false //hides the day values
        set.sliceSpace = 2
        set.colors = [UIColor(hex: "#1f77b4"), UIColor(hex: "#ff7f0e"), UIColor(hex: "#2ca02c"), UIColor(hex: "#d62728"), UIColor(hex: "#9467bd"), UIColor(hex: "#8c564b"), UIColor(hex: "#e377c2")]
        
        // customize the center text
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        var valueAttribute = [NSAttributedStringKey.font: UIFont(name: "Hiragino Sans", size: 36.0)!, NSAttributedStringKey.foregroundColor: valueColor, NSAttributedStringKey.paragraphStyle: paragraphStyle]
        
        let centerText = NSMutableAttributedString(string: String(sum) + "\n" + String((activity?.goalValue)!) + " " + (activity?.goalUnits)!)
        centerText.setAttributes(valueAttribute, range: NSRange(location: 0, length: centerText.length))
        print (String(sum).count)
        
        valueAttribute = [NSAttributedStringKey.font: UIFont(name: "Hiragino Sans", size: 16.0)!, NSAttributedStringKey.foregroundColor: UIColor.black]
        centerText.addAttributes(valueAttribute, range: NSRange(location: String(sum).count, length: centerText.length - String(sum).count))
        
        // finally set the data
        let data = PieChartData(dataSet: set)
        
        // visualize
        cell.chartView.data = data
        
        // assign a center text
        cell.chartView.centerAttributedText = centerText
        cell.chartView.drawCenterTextEnabled = true
        
        // and animate
        cell.chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
}
