//
//  SettingsViewController.swift
//  BMH
//
//  Created by Shreyas Zagade on 3/29/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UITableViewController {

    var tableData : [[ActEx]]!
    let tableSections = ["Activity","Exercise"]
    
    var lastTextField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // check if we came in here for the first time
        if (LoginHelper.getLoginCount(userId: LoginHelper.getLoggedInUser() as! String) <= 1) {
            // hide the settings button
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        }
        
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
        cell.inputTextField.text = String(currentDataElement.goalValue)
        cell.sectionNo = indexPath.section
        cell.indexNo = indexPath.row
        cell.parent = self
        
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
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        lastTextField.resignFirstResponder()
        
        SettingsHelper.saveActivityExerciseGoalValues(activityExerciseAndGoals: tableData)
        
        let alert = UIAlertController(title: "Success!", message: "Your preferences have been saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        if (LoginHelper.getLoginCount(userId: LoginHelper.getLoggedInUser() as! String) <= 1) {
            // increment the login count
            LoginHelper.setLoginCount(userId: LoginHelper.getLoggedInUser() as! String, loginCount: 2)
            
            // now show the settings button
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(red: 62/255.0, green: 100/255.0, blue: 251/255.0, alpha: 1)
            
            // and segue to the main view
            self.performSegue(withIdentifier: "showTabBar", sender: self)
        }
    }
    
    @IBAction func logout() {
        
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
    
}
