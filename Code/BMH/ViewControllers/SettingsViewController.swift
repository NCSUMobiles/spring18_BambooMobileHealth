//
//  SettingsViewController.swift
//  BMH
//
//  Created by Shreyas Zagade on 3/29/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    var tableData : [[ActEx]]!
    let tableSections = ["Activity","Exercise"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // get the activies and exercises data from app delegate
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        tableData = [appDelegate.activities, appDelegate.exercises]
        
        // prevent it from going below the nav bar.
        self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
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
        cell.leftImageView.image = UIImage(named: currentDataElement.imageName);
        cell.nameLabel.text = currentDataElement.name
        cell.unitsLabel.text = currentDataElement.goalUnits + "/" + currentDataElement.goalTime
        
        cell.inputTextField.borderStyle = .none
        cell.inputTextField.layer.backgroundColor = UIColor.white.cgColor
        cell.inputTextField.layer.masksToBounds = false
        cell.inputTextField.layer.shadowColor = UIColor.gray.cgColor
        cell.inputTextField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cell.inputTextField.layer.shadowOpacity = 1.0
        cell.inputTextField.layer.shadowRadius = 0.0
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSections[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }
    
    @IBAction func logout() {
        // logout
        LoginHelper.logOut()
        
        // now go back to login screen
        _ = (UIApplication.shared.delegate as! AppDelegate).setViewControllerOnWindowFromId(storyBoardId: "loginViewController")
    }
    
}
