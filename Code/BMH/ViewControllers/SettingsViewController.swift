//
//  SettingsViewController.swift
//  BMH
//
//  Created by Shreyas Zagade on 3/29/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    let tableData = [
        [
            ["image":"history", "name" : "Running", "units" : "miles/week"],
            ["image":"history", "name" : "Walking", "units" : "steps/week"],
            ["image":"history", "name" : "Jogging", "units" : "miles/week"],
            ["image":"history", "name" : "Climbing", "units" : "ft/week"],
            ["image":"history", "name" : "Cycling", "units" : "miles/week"],
            ["image":"history", "name" : "Activity 1", "units" : "units/week"],
            ["image":"history", "name" : "Activity 2", "units" : "units/week"]
        ],
        [
            ["image":"history", "name" : "Exercise 1", "units" : "sessions/week"],
            ["image":"history", "name" : "Exercise 2", "units" : "sessions/week"],
            ["image":"history", "name" : "Exercise 3", "units" : "sessions/week"],
            ["image":"history", "name" : "Exercise 4", "units" : "sessions/week"],
            ["image":"history", "name" : "Exercise 5", "units" : "sessions/week"],
        ]
    ]
    
    let tableSections = ["Activity","Exercise"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tableData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableData[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsTableViewCell", for: indexPath) as! SettingsTableViewCell
        let currentDataElement = tableData[indexPath.section][indexPath.row];
        cell.leftImageView.image = UIImage(named: currentDataElement["image"]!);
        cell.nameLabel.text = currentDataElement["name"]!
        cell.unitsLabel.text = currentDataElement["units"]!
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "settingsTableViewSectionHeader") as! SettingsTableViewSectionHeader
        sectionHeader.sectionTitleLabel.text = tableSections[section]
        return sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}
