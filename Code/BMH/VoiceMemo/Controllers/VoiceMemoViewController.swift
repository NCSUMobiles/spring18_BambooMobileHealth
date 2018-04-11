//
//  VoiceMemoViewController.swift
//  BMH
//
//  Created by Robert Dates on 3/29/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import Foundation
import UIKit


class VoiceMemoViewController: UITableViewController {
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.register(UINib(nibName: "RecordCategoryTableViewCell" , bundle: nil), forCellReuseIdentifier: "categoryCell")
        tableView.register(UINib(nibName: "RecordFileNamingTableViewCell" , bundle: nil), forCellReuseIdentifier: "namingCell")
        tableView.register(UINib(nibName: "MemoReviewTableViewCell" , bundle: nil), forCellReuseIdentifier: "memoCell")
        tableView.register(UINib(nibName: "RecordInputTableViewCell" , bundle: nil), forCellReuseIdentifier: "recordCell")
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section){
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! RecordInputTableViewCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! RecordCategoryTableViewCell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "namingCell", for: indexPath) as! RecordFileNamingTableViewCell
            return cell
        default:
            
            return UITableViewCell()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch(indexPath.section){
        case 0:
            return 400.0
        case 1:
            return 86.0
        case 2:
            return 168.0
        default:
            return 50.0
            
        }

    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch(indexPath.section){
        case 0:
            return 400.0
        case 1:
            return 86.0
        case 2:
            return 165.0
        default:
            return 50.0
            
        }
    }
}

extension VoiceMemoViewController: RecordCategoryTableViewCellProtocol {
    func redButtonPressed() {
        print("red button pressed")
    }
    
    func yellowButtonPressed() {
        print("yellow button pressed")
    }
    
    func greenButtonPressed() {
        print("green button pressed")
    }
}

extension VoiceMemoViewController: RecordFileNamingTableViewCellProtocol {
    func doneButtonPressed() {
        print("done button pressed")
    }
    
    func sendFileName() {
        print("sendFileName function")
    }
}

extension VoiceMemoViewController: RecordInputTableViewCellProtocol {
    func recordButtonPressed() {
        print("record button pressed")
    }
    
    func previewButtonPressed() {
        print("preview button pressed")
    }
    
    func sendRecordedFile() {
        print("recorded File Function")
    }
}
