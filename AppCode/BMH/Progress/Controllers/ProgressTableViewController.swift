//
//  ProgressTableViewController.swift
//  BMH
//
//  Created by Kalpesh Padia on 4/5/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import Charts
import Firebase
import Alamofire
import FirebaseAuth
import FaveButton

class ProgressTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChartViewDelegate, FaveButtonDelegate {
    
    var showPickerView : Bool = false
    var showPieChart : Bool = true
    var showSlicedPieChart : Bool = false
    var needsFlashing : Bool = false
    
    var activities : [ActEx]!
    var selectedActivity : Int = -1
    var activityData : [String : [Int]]!
    
    var selectionCellReuseIdentifer : String!
    var chartCellReuseIdentifier : String!
    var labelCellReuseIdentifer : String!
    
    let initDaysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let sliceColors = [UIColor(hex: "#1f77b4"), UIColor(hex: "#ff7f0e"), UIColor(hex: "#2ca02c"), UIColor(hex: "#3943B91"), UIColor(hex: "#f71e71"), UIColor(hex: "#8c564b"), UIColor(hex: "#e377c2"), UIColor.lightGray]
    let chartColors = [UIColor(red: 18.0/255.0, green: 121.0/255.0, blue: 201.0/255.0, alpha: 1.0), UIColor.lightGray]
    
    var tap : UITapGestureRecognizer!
    let activityView = UIView()
    
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
        activityData = [:]
        
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
        
        // custom double tap gesture which is added and removed at will
        //        tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture))
        //        tap.numberOfTapsRequired = 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // reload the goals
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.loadFromJSON()
        
        if self.restorationIdentifier == "Progress_ActivityViewController" {
            activities = appDelegate.activities
        }
        else if self.restorationIdentifier == "Progress_ExerciseViewController" {
            activities = appDelegate.exercises
        }
        
        // redraw the chart (to reflect updated settings)
        // remove any existing selection
        let chartCell =  ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))) as! ProgressChartCell)
        chartCell.pieChartView.clear()

        // update the chart in third section first row
        if selectedActivity == -1 {
            createChart(inCell: chartCell, forceFlash: true)
        }
        else {
            createChart(inCell: chartCell, forceFlash: false)
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
        
        // auto-hide the picker view
        //self.tableView(self.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        
        // remove any existing selection
        let chartCell =  ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))) as! ProgressChartCell)
        chartCell.pieChartView.clear()
        
        // update the chart in third section first row
        createChart(inCell: chartCell, forceFlash: false)
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            
            let weekDays = daysOfWeekString(shortFormat: false)
            
            cell.textLabel?.text = weekDays[0] + " — " + weekDays[6]
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: chartCellReuseIdentifier, for: indexPath)
            
            // create chart inside this cell
            if selectedActivity == -1 {
                createChart(inCell: cell as! ProgressChartCell, forceFlash: true)
            }
            else {
                createChart(inCell: cell as! ProgressChartCell, forceFlash: false)
            }
            
            // associate custom handler for touch up inside the toggle buttons in our chart cells
            (cell as! ProgressChartCell).barChartToggle.addTarget(self, action: #selector(toggleChartType(button:)), for: UIControlEvents.touchUpInside)
            (cell as! ProgressChartCell).chartToggleButton.addTarget(self, action: #selector(chartTypeChanged(button:)), for: UIControlEvents.primaryActionTriggered)
            (cell as! ProgressChartCell).starButton.delegate = self
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
            return self.restorationIdentifier == "Progress_ExerciseViewController" ? "Choose an Exercise" : "Choose an Activity"
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
            
            if (needsFlashing) {
                let chartCell = ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))) as! ProgressChartCell)
                chartCell.starButton.sendActions(for: .touchUpInside)
            }
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
        
        if !showSlicedPieChart && cell.pieChartView.highlighted[0].x == 0.0 {
            showSlicedPieChart = true
            cell.barChartToggle.isHidden = false
            cell.chartToggleButton.selectedSegmentIndex = 1
            cell.previousSegmentIndex = cell.currentSegmentIndex
            cell.currentSegmentIndex = 1
            togglePieChartType(button: cell.chartToggleButton)
        }
        
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
    func createDummyData() -> [Int] {
        var dataArr : [Int] = []
        var limit : UInt32 = 300
        
        if self.restorationIdentifier == "Progress_ExerciseViewController" {
            limit = 5
        }
        
        for _ in 0...6 {
            dataArr.append(Int(arc4random_uniform(limit)))
        }
        
        return dataArr
    }
    
    // get the seven days of week
    func daysOfWeekString(shortFormat : Bool) -> [String] {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))
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
    
    // update the value for this week's progress
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
        
        var valueAttribute = [NSAttributedStringKey.font: UIFont(name: "Hiragino Sans", size: 24.0)!, NSAttributedStringKey.foregroundColor: valueColor] as [NSAttributedStringKey : Any]
        let valueString = NSMutableAttributedString(string: String(value), attributes: valueAttribute)
        
        valueAttribute = [NSAttributedStringKey.font: UIFont(name: "Hiragino Sans", size: 20.0)!, NSAttributedStringKey.foregroundColor: valueColor]
        let valueString2 = NSAttributedString(string: " " + (activity?.goalUnits)!, attributes: valueAttribute)
        valueString.append(valueString2)
        cell.valueLabel.attributedText = valueString
        
        // return the color
        return valueColor
    }
    
    
    // Actually draw a chart inside the specified cell with specified data
    func drawChart(inCell cell: ProgressChartCell, withData dataArr: [Int], forceFlash: Bool) {
        if showPieChart {
            // Create a pie chart
            drawPieChart(inCell: cell, withData: dataArr, forceFlash: forceFlash)
            
            // set chart delegate to self
            cell.pieChartView.delegate = self
        }
        else {
            // Create a bar chart
            drawBarChart(inCell: cell, withData: dataArr, forceFlash: forceFlash)
            
            // set chart delegate to self
            cell.barChartView.delegate = self
        }
    }
    
    // retrieve data from backend and draw chart in the specified cell
    func retrieveDataAndDrawChart(inCell cell: ProgressChartCell, forceFlash: Bool) {
        let index = selectedActivity == -1 ? 0 : selectedActivity
        var dataArr : [Int] = []
        
        let activity = activities[index]
        let code = activity.code
        
        if activityData[code] != nil {
            self.drawChart(inCell: cell, withData: activityData[code]!, forceFlash: forceFlash)
            return
        }
        
        // start the spinner
        self.tableView.addSubview(self.activityView)
        
        var idToken = ""
        // get current ID Token
        Auth.auth().currentUser?.getIDToken(completion: { (token, error) in
            if (error == nil) {
                idToken = token!
                
                let params = ["uname": LoginHelper.getLoggedInUser() as! String,
                              "token": idToken,
                              "act"  : self.restorationIdentifier == "Progress_ActivityViewController" ? 1 : 0,
                              "name" : code] as [String : Any]
                
                // make a request to API
                Alamofire.request(
                    URL(string: "http://" + (UIApplication.shared.delegate as! AppDelegate).serverIP + "/api/progress")!,
                    method: .get,
                    parameters: params)
                    .responseJSON { (response) -> Void in
                        let ret_code = response.response?.statusCode
                        if ret_code == 200 {
                            self.activityView.removeFromSuperview()
                            var res_json = response.result.value as? [String: Int]
                            
                            let currWeekDay = Calendar.current.dateComponents([.weekday], from: Date()).weekday! - 1
                            for i in 0..<7 {
                                let weekDay = self.initDaysOfWeek[i]
                                if (i <= currWeekDay) {
                                    dataArr.append(res_json![weekDay] ?? 0)
                                }
                                else {
                                    dataArr.append(0)
                                }
                            }
                            self.activityData[code] = dataArr
                            self.drawChart(inCell: cell, withData: dataArr, forceFlash: forceFlash)
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
                            self.drawChart(inCell: cell, withData: dataArr, forceFlash: forceFlash) // show no data available message
                        }
                        else {
                            print ("Some other error.")
                            self.activityView.removeFromSuperview()
                            AlertHelper.showBasicAlertInVC(self, title: "Oops!", message: "Something went wrong. Could not retrieve data.")
                            self.drawChart(inCell: cell, withData: dataArr, forceFlash: forceFlash) // show no data available message
                        }
                }
            }
            else {
                print("Error occurred in getting IDToken: \(String(describing: error))")
                // remove the spinner
                self.activityView.removeFromSuperview()
                AlertHelper.showBasicAlertInVC(self, title: "Oops!", message: "Something went wrong. Could not retrieve data.")
                self.drawChart(inCell: cell, withData: dataArr, forceFlash: forceFlash) // show no data available message
            }
        })
    }
    
    // Create a chart inside the specified cell, creating data as necessary
    func createChart(inCell cell: ProgressChartCell, forceFlash: Bool) {
        // Configure the cell...
        // For this activity obtain weekly goal value and units
        let index = selectedActivity == -1 ? 0 : selectedActivity
        let activity = activities[index]
        
        // save activity into cell for futture use
        cell.actEx = activity

        retrieveDataAndDrawChart(inCell: cell, forceFlash: forceFlash)
        
        // check if flashing is required
        if selectedActivity == -1 {
            
        }
    }
    
    // draw a pie chart
    func drawPieChart(inCell cell: ProgressChartCell, withData initValues: [Int], forceFlash : Bool) {
        
        if initValues.count == 0 {
            cell.pieChartView!.data = nil
            return
        }
        
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
        
        // also draw the star if required
        let goalPercent = Double(sum) * 100.0 / Double((activity?.goalValue)!)
        
        if (goalPercent > 100) {
            cell.starButton.isHidden = false
            needsFlashing = true
            if (forceFlash) {
                cell.starButton.sendActions(for: .touchUpInside)
            }
        }
        else {
            //cell.starButton.setImage(nil, for: .normal)
            cell.starButton.isHidden = true
        }
    }
    
    // draw a bar chart
    func drawBarChart(inCell cell: ProgressChartCell, withData initValues: [Int], forceFlash : Bool) {
        
        if initValues.count == 0 {
            cell.barChartView!.data = nil
            return
        }
        
        // get the activity object for this cell
        let activity = cell.actEx
        
        let chartView = cell.barChartView!
        let formatter:BarChartFormatter = BarChartFormatter()
        
        var values : [Int] = []
        var setColors : [UIColor] = []
        var sum = 0
        
        // calculate percent of goal achieved to customize label color
        for i in 0...6 {
            //if (initValues[i] > 0) {
                sum += initValues[i]
                values.append(initValues[i])
                setColors.append(sliceColors[i])
           // }
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
        
        chartView.drawBordersEnabled = true
        chartView.borderColor = UIColor.init(hex: "#777777")
        cell.barChartView.borderLineWidth = 0.5
        
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
        
        // also draw the star if required
        let goalPercent = Double(sum) * 100.0 / Double((activity?.goalValue)!)
        
        if (goalPercent > 100 ) {
            cell.starButton.isHidden = false
            needsFlashing = true
            if (forceFlash) {
                cell.starButton.sendActions(for: .touchUpInside)
            }
        }
        else {
            //cell.starButton.setImage(nil, for: .normal)
            cell.starButton.isHidden = true
        }
    }
    
    // MARK: - Custom IBActions for controlling the chart type
    // toggle between filled and segmented pie chart
    
    @objc func chartTypeChanged(button: UISegmentedControl) {
        let cell = (button.superview?.superview?.superview?.superview) as! ProgressChartCell
        cell.previousSegmentIndex = cell.currentSegmentIndex
        cell.currentSegmentIndex = button.selectedSegmentIndex
        
        if (cell.previousSegmentIndex == 0) {
            if (cell.currentSegmentIndex == 1) {
                // toggle the state of Pie Chart
                showSlicedPieChart = true
                cell.barChartToggle.isHidden = false
                togglePieChartType(button: button)
            }
        }
        else if (cell.previousSegmentIndex == 1) {
            if (cell.currentSegmentIndex == 0) {
                showSlicedPieChart = false
                if (!showPieChart){
                    toggleChartType(button: cell.barChartToggle)
                }
                cell.barChartToggle.isHidden = true
                togglePieChartType(button: button)
            }
        }
    }
    
    @objc func togglePieChartType (button : UISegmentedControl) {
        if (showSlicedPieChart) {
            // switch the image for the button
            // button.setImage(UIImage(named: "donut-single"), for: UIControlState.normal)
            print ("Now showing donut-multi")
        }
        else {
            // switch the image for the button
            // button.setImage(UIImage(named: "donut-multi"), for: UIControlState.normal)
            print ("Now showing donut-single")
        }
        
        // update the chart
        let cell = ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))) as! ProgressChartCell)
        
        if selectedActivity == -1 {
            cell.pieChartView.clear()
            createChart(inCell: cell, forceFlash: false)
        }
        else {
            cell.pieChartView.clear()
            createChart(inCell: cell, forceFlash: false)
        }
    }
    
    // toggle between pie chart and bar chart
    @objc func toggleChartType(button : UIButton) {
        let cell = ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))) as! ProgressChartCell)
        
        // toggle the state of Pie Chart
        showPieChart = !showPieChart
        
        if (showPieChart) {
            // switch the image for the button
            button.setImage(UIImage(named: "bar-chart"), for: UIControlState.normal)
            button.imageEdgeInsets = UIEdgeInsetsMake(4,4,4,4) // hack because we don't have padding for the bar chart icon
            print ("Now showing pie chart")
            
            // update the chartview visibility
            cell.pieChartView.isHidden = false
            cell.barChartView.isHidden = true
            // cell.pieChartToggle.isHidden = false
        }
        else {
            // switch the image for the button
            
            button.setImage(UIImage(named: "donut-multi"), for: UIControlState.normal)
            button.imageEdgeInsets = UIEdgeInsetsMake(2,2,2,2)
            print ("Now showing bar chart")
            
            // update the chartview visibility
            cell.pieChartView.isHidden = true
            cell.barChartView.isHidden = false
            // cell.pieChartToggle.isHidden = true
        }
        
        // draw new chart
        if selectedActivity == -1 {
            createChart(inCell: cell, forceFlash: false)
        }
        else {
            createChart(inCell: cell, forceFlash: false)
        }
    }
    
    // MARK: - Custom gestures for piechartview
    @objc func doubleTapGesture() {
        print ("double tap recognized")
        let cell = ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))) as! ProgressChartCell)
        if cell.pieChartView.highlighted[0].x == 0.0 {
            cell.chartToggleButton.selectedSegmentIndex = cell.chartToggleButton.selectedSegmentIndex == 0 ? 1 : 0;
            togglePieChartType(button: cell.chartToggleButton)
        }
    }
    
    // MARK: - FaveButton Delegate
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool)  {
        let activity = activities[selectedActivity == -1 ? 0 : selectedActivity]
        AlertHelper.showBasicAlertInVC(self, title: "Congratulations!", message: "You have met your goal of \(activity.goalValue) \(activity.goalUnits) this week.")
        needsFlashing = false
    }
}
