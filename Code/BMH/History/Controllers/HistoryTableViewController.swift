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
import Firebase
import Alamofire
import FirebaseAuth

class HistoryTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChartViewDelegate {
    
    var showPickerView : Bool = false
    var activities : [ActEx]!
    var selectedActivity : Int = -1
    var activityData : [String : [String : [Int]]]!
    var chartRange : String = ""
    var chartTitle : String = ""
    var chartDate : Date = Date()
    
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
    //weak var axisFormatDelegate: IAxisValueFormatter?
    
    var selectedSegment = 1
    let initDaysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    // mocking data for one year
    var yearData  = Array(repeating: Array(repeating: 0, count: 4), count: 12)
    var monthData = Array(repeating: Array(repeating: 0, count: 7), count: 4)
    var weekData =  Array(repeating: Array(repeating: 0, count: 24), count: 7)
    
    var dataLabel: [String]!
    var dataValue = [Int]()
    
    let activityView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // load the activity list and register custom nibs depending on the scene
        activities = []
        activityData = [:]
        
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
        
        activityView.frame = self.tableView.frame
        activityView.center = self.tableView.center
        activityView.backgroundColor = UIColor(hex: "#ffffff", alpha: 0.3)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = self.tableView.center
        loadingView.backgroundColor = UIColor(hex: "#444444", alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2,
                                y: loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        activityView.addSubview(loadingView)
        actInd.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // reload the goals
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.loadFromJSON()
        
        if self.restorationIdentifier == "History_ActivityViewController" {
            activities = appDelegate.activities
        }
        else if self.restorationIdentifier == "History_ExerciseViewController" {
            activities = appDelegate.exercises
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
        selectedActivity = row
        print("Selected \(activityDebugLabel) \"\(activities[selectedActivity].name)\"")
        
        // update the text in first section first row
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)))?.textLabel?.text = activities[selectedActivity].name
        
        // remove any existing selection
        let chartCell =  ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))) as! HistoryCell)
        chartCell.barChartView.clear()
        
        // update the chart in third section first row
        // construct the ranges
        var rangeAndTitle = getChartRangeAndTitle(forDate: chartDate)
        chartRange = rangeAndTitle[0]
        chartTitle = rangeAndTitle[1]
        
        // update the cell's top label
        chartCell.topLabel.text = chartTitle
        
        // and draw the chart
        createChart(inCell: chartCell)
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
            
            //cell.aggSwitch.addTarget(self, action: #selector(changeChart(sender:)), for: UIControlEvents.primaryActionTriggered)
            cell.aggSwitch.addTarget(self, action: #selector(updateChart(sender:)), for: .valueChanged)
            
            cell.leftButton.addTarget(self, action: #selector(createChartForPreviousRange(sender:)), for: .primaryActionTriggered)
            cell.rightButton.addTarget(self, action: #selector(createChartForNextRange(sender:)), for: .primaryActionTriggered)
            
            // get latest ranges
            var rangeAndTitle = getChartRangeAndTitle(forDate: Date())
            chartRange = rangeAndTitle[0]
            chartTitle = rangeAndTitle[1]
            
            // update the cell's top label
            cell.topLabel.text = chartTitle
            
            // and draw the chart
            createChart(inCell: cell)
            
            return cell
        }
    }
    
    // Set the title for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return self.restorationIdentifier == "History_ExerciseViewController" ? "Choose an Exercise" : "Choose an Activity"
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
    
    @IBAction func createChartForPreviousRange(sender: UIButton) {
        print ("Previous Selected")
        let cell = (sender.superview?.superview?.superview?.superview?.superview as? HistoryCell)!
        cell.rightButton.isEnabled = true
        
        // get previous range
        getPreviousRange()
        
        // update the cell's top label
        cell.topLabel.text = chartTitle
        
        // and draw the chart
        createChart(inCell: cell)
    }
    
    @IBAction func createChartForNextRange(sender: UIButton) {
        print ("Next Selected")
        let cell = (sender.superview?.superview?.superview?.superview?.superview as? HistoryCell)!
        
        // get next range
        getNextRange()
        
        // update the cell's top label
        cell.topLabel.text = chartTitle
        
        // and draw the chart
        createChart(inCell: cell)
        
        // now figure out if the right button has to be disabled
        var testRange = getChartRangeAndTitle(forDate: Date())
        var testDate = Date()
        var dateToCheck = Date()
        
        let dateFormatter = DateFormatter()
        
        switch selectedSegment {
        case 1:
            dateFormatter.dateFormat = "MM-dd-yy"
            dateToCheck = dateFormatter.date(from: chartRange)!
            testDate = dateFormatter.date(from: testRange[0])!
            break;
        case 2:
            dateFormatter.dateFormat = "MM-dd-yy"
            dateToCheck = dateFormatter.date(from: String(chartRange.split(separator: " ")[1]))!
            testDate = dateFormatter.date(from: String(testRange[0].split(separator: " ")[1]))!
            break;
        case 3:
            dateFormatter.dateFormat = "MM-yy"
            dateToCheck = dateFormatter.date(from: chartRange)!
            testDate = dateFormatter.date(from: testRange[0])!
            break;
        default:
            dateFormatter.dateFormat = "yyyy"
            dateToCheck = dateFormatter.date(from: chartRange)!
            testDate = dateFormatter.date(from: testRange[0])!
            break;
        }
        
        if (testDate <= dateToCheck) {
            cell.rightButton.isEnabled = false
        }
    }
    
    @objc func updateChart(sender: UISegmentedControl) {
        let cell = (sender.superview?.superview as? HistoryCell)!
        //cell.rightButton.isEnabled = true
        
        var testDate : Date
        var dateToCheck : Date
        let dateFormatter = DateFormatter()
        let gregorian = Calendar(identifier: .gregorian)
        
        let prevSegment = selectedSegment;
        
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
        
        // get range and title
        var rangeAndTitle = getChartRangeAndTitle(forDate: chartDate)
        chartRange = rangeAndTitle[0]
        chartTitle = rangeAndTitle[1]
        
        // correct it if going to Day view from Current Year, Month or Week.
        if (selectedSegment == 1) {
            switch prevSegment {
            case 2:
                let weekdays = daysOfWeekDate(shortFormat: true, startDate: Date())
                dateFormatter.dateFormat = "MM-dd-yy"
                testDate = dateFormatter.date(from: chartRange)!
                
                if ( (gregorian.compare(weekdays[0], to: testDate, toGranularity:.day) == .orderedAscending || gregorian.compare(weekdays[0], to: testDate, toGranularity:.day) == .orderedSame) && (gregorian.compare(weekdays[6], to: testDate, toGranularity:.day) == .orderedDescending || gregorian.compare(weekdays[6], to: testDate, toGranularity:.day) == .orderedSame)) {
                    chartDate = Date()
                    rangeAndTitle = getChartRangeAndTitle(forDate: chartDate)
                    chartRange = rangeAndTitle[0]
                    chartTitle = rangeAndTitle[1]
                }
                break;
            case 3:
                dateFormatter.dateFormat = "MM-dd-yy"
                testDate = Date()
                let dateComps = chartRange.split(separator: "-")
                let startOfMonth = dateFormatter.date(from: String(dateComps[0]) + "-15-" + String(dateComps[2]))
                var endOfMonth = gregorian.date(byAdding: .month, value: 1, to: startOfMonth!)
                endOfMonth = gregorian.date(byAdding: .day, value: -1, to: endOfMonth!)
                
                
                if ( (gregorian.compare(startOfMonth!, to: testDate, toGranularity:.day) == .orderedAscending || gregorian.compare(startOfMonth!, to: testDate, toGranularity:.day) == .orderedSame) && (gregorian.compare(endOfMonth!, to: testDate, toGranularity:.day) == .orderedDescending || gregorian.compare(endOfMonth!, to: testDate, toGranularity:.day) == .orderedSame)) {
                    chartDate = Date()
                    rangeAndTitle = getChartRangeAndTitle(forDate: chartDate)
                    chartRange = rangeAndTitle[0]
                    chartTitle = rangeAndTitle[1]
                }
                break;
            case 4:
                dateFormatter.dateFormat = "MM-dd-yy"
                testDate = Date()
                let dateComps = chartRange.split(separator: "-")
                let startOfYear = dateFormatter.date(from: "01-01-" + String(dateComps[2]))
                var endOfYear = gregorian.date(byAdding: .year, value: 1, to: startOfYear!)
                endOfYear = gregorian.date(byAdding: .day, value: -1, to: endOfYear!)
                
                
                if ( (gregorian.compare(startOfYear!, to: testDate, toGranularity:.day) == .orderedAscending || gregorian.compare(startOfYear!, to: testDate, toGranularity:.day) == .orderedSame) && (gregorian.compare(endOfYear!, to: testDate, toGranularity:.day) == .orderedDescending || gregorian.compare(endOfYear!, to: testDate, toGranularity:.day) == .orderedSame)) {
                    chartDate = Date()
                    rangeAndTitle = getChartRangeAndTitle(forDate: chartDate)
                    chartRange = rangeAndTitle[0]
                    chartTitle = rangeAndTitle[1]
                }
            default:
                break;
            }
            print ("Correct range is \(chartRange)")
        }

        // update the cell's top label
        cell.topLabel.text = chartTitle
        
        // and draw the chart
        createChart(inCell: cell)
        
        // figure out if the right button has to be disabled
        var testRange = getChartRangeAndTitle(forDate: Date())
        switch selectedSegment {
        case 1:
            dateFormatter.dateFormat = "MM-dd-yy"
            dateToCheck = dateFormatter.date(from: chartRange)!
            testDate = dateFormatter.date(from: testRange[0])!
            break;
        case 2:
            dateFormatter.dateFormat = "MM-dd-yy"
            dateToCheck = dateFormatter.date(from: String(chartRange.split(separator: " ")[1]))!
            testDate = dateFormatter.date(from: String(testRange[0].split(separator: " ")[1]))!
            break;
        case 3:
            dateFormatter.dateFormat = "MM-yy"
            dateToCheck = dateFormatter.date(from: chartRange)!
            testDate = dateFormatter.date(from: testRange[0])!
            break;
        default:
            dateFormatter.dateFormat = "yyyy"
            dateToCheck = dateFormatter.date(from: chartRange)!
            testDate = dateFormatter.date(from: testRange[0])!
            break;
        }
        
        if (testDate <= dateToCheck) {
            cell.rightButton.isEnabled = false
        } else {
            cell.rightButton.isEnabled = true
        }
    }
    
    // MARK: - Custom functions
    // get the seven days of week
    func daysOfWeekString(shortFormat : Bool, startDate : Date) -> [String] {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startDate))
        var daysString : [String] = []
        let format = DateFormatter()
        format.timeStyle = .none
        
        if (shortFormat) {
            format.dateStyle = .short
            format.dateFormat = "MM-dd-yy"
        }
        else {
            format.dateStyle = .long
        }
        
        for i in (0...6) {
            daysString.append(format.string(from: gregorian.date(byAdding: .day, value: i, to: sunday!)!))
        }
        
        return daysString
    }
    
    func daysOfWeekDate(shortFormat : Bool, startDate : Date) -> [Date] {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startDate))
        var days : [Date] = []
        let format = DateFormatter()
        format.timeStyle = .none
        
        if (shortFormat) {
            format.dateStyle = .short
            format.dateFormat = "MM-dd-yy"
        }
        else {
            format.dateStyle = .long
        }
        
        for i in (0...6) {
            days.append(gregorian.date(byAdding: .day, value: i, to: sunday!)!)
        }
        
        return days
    }
    
    func getChartRangeAndTitle(forDate selectedDate: Date) -> [String]{
        var range = ""
        var rangeString = ""
        switch selectedSegment {
        case 1:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yy"
            range = dateFormatter.string(from: selectedDate)
            
            dateFormatter.dateStyle = .long
            rangeString = dateFormatter.string(from: selectedDate) == dateFormatter.string(from: Date()) ? "Today" : dateFormatter.string(from: selectedDate)
            break;
        case 2:
            var weekDays = daysOfWeekString(shortFormat: true, startDate: selectedDate)
            range = weekDays[0] + " " + weekDays[6]
            
            weekDays = daysOfWeekString(shortFormat: false, startDate: selectedDate)
            rangeString = weekDays[0] + " — " + weekDays[6]
            break;
        case 3:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-yy"
            range = dateFormatter.string(from: selectedDate)
            
            dateFormatter.dateFormat = "MMMM yyyy"
            rangeString = dateFormatter.string(from: selectedDate)
            break;
        default:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            range = dateFormatter.string(from: selectedDate)
            
            rangeString = range
            break;
        }
        print ("Range is \(range)")
        return [range, rangeString]
    }
    
    func getPreviousRange(){
        let gregorian = Calendar(identifier: .gregorian)
        let dateFormatter = DateFormatter()
        
        switch selectedSegment {
        case 1:
            dateFormatter.dateFormat = "MM-dd-yy"
            let selectedDate = dateFormatter.date(from: chartRange)
            
            chartDate = gregorian.date(byAdding: .day, value: -1, to: selectedDate!)! // prev day
            break;
        case 2:
            dateFormatter.dateFormat = "MM-dd-yy"
            let selectedDate = dateFormatter.date(from: String(chartRange.split(separator: " ")[0]))
            
            chartDate = gregorian.date(byAdding: .day, value: -4, to: selectedDate!)! // prev Wed
            break;
        case 3:
            dateFormatter.dateFormat = "dd-MM-yy"
            chartDate = gregorian.date(byAdding: .month, value: -1, to: dateFormatter.date(from: "15-" + chartRange)!)! // prev month 15th
            break;
        default:
            dateFormatter.dateFormat = "MM-dd-yyyy"
            chartDate = gregorian.date(byAdding: .year, value: -1, to: dateFormatter.date(from: "12-15-" + chartRange)!)! // prev year Dec
            break;
        }
        
        var rangeAndTitle = getChartRangeAndTitle(forDate: chartDate)
        chartRange = rangeAndTitle[0]
        chartTitle = rangeAndTitle[1]
    }
    
    func getNextRange(){
        let gregorian = Calendar(identifier: .gregorian)
        let dateFormatter = DateFormatter()
        
        switch selectedSegment {
        case 1:
            dateFormatter.dateFormat = "MM-dd-yy"
            var selectedDate = dateFormatter.date(from: chartRange)
            selectedDate = gregorian.date(byAdding: .day, value: +1, to: selectedDate!)! // next day
            
            if (gregorian.compare(selectedDate!, to: Date(), toGranularity: .day) == .orderedDescending) {
                chartDate = Date()
            }
            else {
                chartDate = selectedDate!
            }
            break;
        case 2:
            dateFormatter.dateFormat = "MM-dd-yy"
            var selectedDate = dateFormatter.date(from: String(chartRange.split(separator: " ")[1]))
            selectedDate = gregorian.date(byAdding: .day, value: +4, to: selectedDate!)! // next Wed
            
            if (gregorian.compare(selectedDate!, to: Date(), toGranularity: .day) == .orderedDescending) {
                chartDate = Date()
            }
            else if (gregorian.compare(selectedDate!, to: Date(), toGranularity: .day) == .orderedSame) {
                chartDate = Date()
            }
            else {
                chartDate = selectedDate!
            }
            break;
        case 3:
            dateFormatter.dateFormat = "dd-MM-yy"
            let selectedDate = gregorian.date(byAdding: .month, value: +1, to: dateFormatter.date(from: "15-" + chartRange)!)! // next month 15th
            if (gregorian.compare(selectedDate, to: Date(), toGranularity: .day) == .orderedDescending) {
                chartDate = Date()
            }
            else if (gregorian.compare(selectedDate, to: Date(), toGranularity: .month) == .orderedSame) {
                chartDate = Date()
            }
            else {
                chartDate = selectedDate
            }
            break;
        default:
            dateFormatter.dateFormat = "MM-dd-yyyy"
            let selectedDate = gregorian.date(byAdding: .year, value: +1, to: dateFormatter.date(from: "01-15-" + chartRange)!)! // next year Jan
            if (gregorian.compare(selectedDate, to: Date(), toGranularity: .day) == .orderedDescending) {
                chartDate = Date()
            }
            else if (gregorian.compare(selectedDate, to: Date(), toGranularity: .year) == .orderedSame) {
                chartDate = Date()
            }
            else
            {
                chartDate = selectedDate
            }
            break;
        }
        
        var rangeAndTitle = getChartRangeAndTitle(forDate: chartDate)
        chartRange = rangeAndTitle[0]
        chartTitle = rangeAndTitle[1]
    }
    
    // Create a chart
    func createChart(inCell cell: HistoryCell) {
        let index = selectedActivity == -1 ? 0 : selectedActivity
        let activity = activities[index]
        
        // save activity into cell for future use
        cell.actEx = activity
        
        //cell.barChartView.delegate = self
        
        retrieveDataAndDrawChart(inCell: cell)
    }
    
    // retrieve data from backend and draw chart in the specified cell
    func retrieveDataAndDrawChart(inCell cell: HistoryCell) {
        let index = selectedActivity == -1 ? 0 : selectedActivity
        var dataArr : [Int] = []
        
        let activity = activities[index]
        let code = activity.code
        let range = self.chartRange
        
        var gran = ""
        switch selectedSegment {
        case 1: gran = "d"
        break;
        case 2: gran = "w"
        break;
        case 3: gran = "m"
        break;
        default: gran = "y"
        break;
        }
        
        if activityData[code] != nil &&  activityData[code]![range] != nil {
            self.drawChart(inCell: cell, withData: activityData[code]![range]!)
            return
        }
        
        // start the spinner
        self.tableView.addSubview(self.activityView)
        
        var idToken = ""
        // get current ID Token
        Auth.auth().currentUser?.getIDToken(completion: { (token, error) in
            if (error == nil) {
                idToken = token!
                print ("Token is \(idToken)")
                
                let params = ["uname": LoginHelper.getLoggedInUser() as! String,
                              "token": idToken,
                              "act"  : self.restorationIdentifier == "History_ActivityViewController" ? 1 : 0,
                              "name" : code,
                              "gran" : gran,
                              "range": range
                    ] as [String : Any]
                
                // make a request to API
                Alamofire.request(
                    URL(string: "http://" + (UIApplication.shared.delegate as! AppDelegate).serverIP + "/api/history")!,
                    method: .get,
                    parameters: params)
                    .responseJSON { (response) -> Void in
                        let ret_code = response.response?.statusCode
                        if ret_code == 200 {
                            self.activityView.removeFromSuperview()
                            var res_json = response.result.value as? [String: Int]
                            
                            if (self.selectedSegment == 2) {
                                for i in self.initDaysOfWeek {
                                    dataArr.append(res_json![i] ?? 0)
                                }
                            }
                            else {
                                let keys = Array(res_json!.keys)
                                for key in keys.sorted(by: <) {
                                    // Get value for this key.
                                    if let value = res_json![key] {
                                        dataArr.append(value)
                                    }
                                }
                            }
                            if self.activityData[code] == nil {
                                self.activityData[code] = [:]
                            }
                            self.activityData[code]![range] = dataArr
                            self.drawChart(inCell: cell, withData: dataArr)
                        }
                        else if ret_code == 403 {
                            self.activityView.removeFromSuperview()
                            // unauthorized user. log the user out
                            AlertHelper.showBasicAlertInVC(self, title: "Unauthorized", message: "You are not authorized to retrieve this content. Please sign in using appropriate credentials and try agian.")
                            
                            let firebaseAuth = Auth.auth()
                            do {
                                try firebaseAuth.signOut()
                            } catch let signOutError as NSError {
                                print ("Error signing out: %@", signOutError)
                            }
                            
                            // logout
                            LoginHelper.logOut()
                            
                            // now go back to login screen
                            _ = (UIApplication.shared.delegate as! AppDelegate).setViewControllerOnWindowFromId(storyBoardId: "loginViewController")
                        }
                        else if ret_code == 401 {
                            self.activityView.removeFromSuperview()
                            AlertHelper.showBasicAlertInVC(self, title: "Session Expired", message: "Please sign in again to retrieve the latest data from the server.")
                            
                            let firebaseAuth = Auth.auth()
                            do {
                                try firebaseAuth.signOut()
                            } catch let signOutError as NSError {
                                print ("Error signing out: %@", signOutError)
                            }
                            
                            // logout
                            LoginHelper.logOut()
                            
                            // now go back to login screen
                            _ = (UIApplication.shared.delegate as! AppDelegate).setViewControllerOnWindowFromId(storyBoardId: "loginViewController")
                        }
                        else if ret_code == 400 {
                            print ("Malformed request.")
                            self.activityView.removeFromSuperview()
                            AlertHelper.showBasicAlertInVC(self, title: "Oops!", message: "Something went wrong. Could not retrieve data.")
                            self.drawChart(inCell: cell, withData: dataArr) // show no data available message
                        }
                        else {
                            print ("Some other error.")
                            self.activityView.removeFromSuperview()
                            AlertHelper.showBasicAlertInVC(self, title: "Oops!", message: "Something went wrong. Could not retrieve data.")
                            self.drawChart(inCell: cell, withData: dataArr) // show no data available message
                        }
                }
            }
            else {
                print("Error occurred in getting IDToken: \(String(describing: error))")
                // remove the spinner
                self.activityView.removeFromSuperview()
                AlertHelper.showBasicAlertInVC(self, title: "Oops!", message: "Something went wrong. Could not retrieve data.")
                self.drawChart(inCell: cell, withData: dataArr) // show no data available message
            }
        })
    }
    
    func drawChart(inCell cell: HistoryCell, withData data_Value: [Int]) {
        var dataValue_ = data_Value
        
        if dataValue_.count == 0 {
            cell.barChartView!.data = nil
            return
        }
        
        var sum = 0
        var dataEntries:[BarChartDataEntry] = []
        
        let activity = cell.actEx
        // TODO: only get Walking activity here
        //        print("activity", activity)
        let chartView = cell.barChartView!
        let d_formatter: DayFormatter = DayFormatter()
        let w_formatter: WeekFormatter = WeekFormatter()
        let m_formatter: MonthFormatter = MonthFormatter()
        let y_formatter: YearFormatter = YearFormatter()
        var formatter : IAxisValueFormatter
        
        //axisFormatDelegate = self as IAxisValueFormatter
        
        for i in 0..<dataValue_.count{
            //            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(dataValue_[i]) , data: dataLabel_ as AnyObject?)
            sum += dataValue_[i]
            //            dataValue_.append(dataValue[i])
            //            dataEntries.append(dataEntry)
        }
        
        if (sum == 0) {
            cell.barChartView!.data = nil
            return
        }
        
        if selectedSegment == 1 {
            dataEntries = (0..<dataValue_.count).map { (i) -> BarChartDataEntry in
                _ = d_formatter.stringForValue(Double(i), axis: chartView.xAxis)
                return BarChartDataEntry(x: Double(i), y: Double(dataValue_[i]))
            }
            formatter = d_formatter;
        } else if selectedSegment == 2 {
            dataEntries = (0..<dataValue_.count).map { (i) -> BarChartDataEntry in
                _ = w_formatter.stringForValue(Double(i), axis: chartView.xAxis)
                return BarChartDataEntry(x: Double(i), y: Double(dataValue_[i]))
            }
            formatter = w_formatter;
        } else if selectedSegment == 3 {
            dataEntries = (0..<dataValue_.count).map { (i) -> BarChartDataEntry in
                _ = m_formatter.stringForValue(Double(i), axis: chartView.xAxis)
                return BarChartDataEntry(x: Double(i), y: Double(dataValue_[i]))
            }
            formatter = m_formatter;
        } else {
            dataEntries = (0..<dataValue_.count).map { (i) -> BarChartDataEntry in
                _ = y_formatter.stringForValue(Double(i), axis: chartView.xAxis)
                return BarChartDataEntry(x: Double(i), y: Double(dataValue_[i]))
            }
            formatter = y_formatter;
        }
        
        let xAxis = cell.barChartView.xAxis
        let leftAxis = cell.barChartView.leftAxis
        let rightAxis = cell.barChartView.rightAxis
        
        xAxis.enabled = true
        xAxis.labelPosition = .bottom
        xAxis.granularity = dataValue_.count > 7 ? 3 : 1
        xAxis.labelCount = dataValue_.count
        xAxis.valueFormatter = formatter
        
        xAxis.drawGridLinesEnabled = true
        xAxis.gridColor = UIColor.init(hex: "#aaaaaa")
        xAxis.gridLineDashLengths = [3.0, 3.0]
        xAxis.drawLimitLinesBehindDataEnabled = true
        xAxis.avoidFirstLastClippingEnabled = false
        
        rightAxis.labelPosition = .outsideChart
        rightAxis.gridLineDashLengths = [3.0, 3.0]
        rightAxis.gridColor = UIColor.init(hex: "#aaaaaa")
        
        leftAxis.labelPosition = .outsideChart
        leftAxis.gridLineDashLengths = [3.0, 3.0]
        leftAxis.gridColor = UIColor.init(hex: "#aaaaaa")
        
        
        rightAxis.axisMinimum = 0
        leftAxis.axisMinimum = 0
        
        /*
         if (selectedSegment == 1) {
         rightAxis.axisMinimum = 0
         leftAxis.axisMinimum = 0
         }
         else {
         rightAxis.resetCustomAxisMin()
         leftAxis.resetCustomAxisMin()
         }
         */
        
        cell.barChartView.legend.enabled = false
        cell.barChartView.drawBordersEnabled = true
        cell.barChartView.borderColor = UIColor.init(hex: "#777777")
        cell.barChartView.borderLineWidth = 0.5
        
        let labelString = (activity?.goalUnits)! + " Count"
        //        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Steps Count")
        let chartDataSet = BarChartDataSet(values: dataEntries, label: labelString)
        
        // customize the data set
        chartDataSet.drawIconsEnabled = false
        //        chartDataSet.drawValuesEnabled = false // hides the value of each day
        
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
        cell.barChartView.setScaleEnabled(false)
    }
    
}
