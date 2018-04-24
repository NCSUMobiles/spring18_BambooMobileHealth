//
//  VoiceMemoViewController.swift
//  BMH
//
//  Created by Robert Dates on 3/29/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import RSSelectionMenu
import Speech
import Firebase


class VoiceMemoViewController: UITableViewController {

    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    let simpleDataArray = ["#Running","#Exercise","#Breathing"]
    var simpleSelectedArray = [String]()
    var category:Int!
    var audioFile:URL!
    var fileName:String!
    
    
    
    func showAsPopover(_ sender: UIView) {
        
        // Show as Popover with datasource
        
        let selectionMenu = RSSelectionMenu(selectionType: .Multiple, dataSource: simpleDataArray, cellType: .Basic) { (cell, object, indexPath) in
            cell.textLabel?.text = object
            cell.frame.size.height = 40.0
        }
        
        selectionMenu.setSelectedItems(items: simpleSelectedArray) { (text, isSelected, selectedItems) in
            
            // update your existing array with updated selected items, so when menu presents second time updated items will be default selected.
            self.simpleSelectedArray = selectedItems
        }
        
        // show as popover
        // Here specify popover sourceView and size of popover
        // specifying nil will present with default size
        
        selectionMenu.show(style: .Popover(sourceView: sender, size: nil), from: self)
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.register(UINib(nibName: "RecordCategoryTableViewCell" , bundle: nil), forCellReuseIdentifier: "categoryCell")
        tableView.register(UINib(nibName: "RecordFileNamingTableViewCell" , bundle: nil), forCellReuseIdentifier: "namingCell")
        tableView.register(UINib(nibName: "MemoReviewTableViewCell" , bundle: nil), forCellReuseIdentifier: "memoCell")
        tableView.register(UINib(nibName: "RecordInputTableViewCell" , bundle: nil), forCellReuseIdentifier: "recordCell")
        tableView.register(UINib(nibName: "HashtagPickerTableViewCell" , bundle: nil), forCellReuseIdentifier: "hashtagCell")
        
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            try self.recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("granted recording permission")
                        //Allow recording
                        
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            let cell = tableView.cellForRow(at: indexPath) as! HashtagPickerTableViewCell
            showAsPopover(cell)
            
        }
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
            cell.delegate = self
            cell.recordingSession = self.recordingSession
            cell.audioRecorder = self.audioRecorder
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! RecordCategoryTableViewCell
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "hashtagCell", for: indexPath) as! HashtagPickerTableViewCell
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "namingCell", for: indexPath) as! RecordFileNamingTableViewCell
            cell.delegate = self
            return cell
        default:
            
            return UITableViewCell()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch(indexPath.section){
        case 0:
            return 300.0
        case 1:
            return 86.0
        case 2:
            return 55.0
        case 3:
            return 168.0
        default:
            return 50.0
            
        }

    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch(indexPath.section){
        case 0:
            return 300.0
        case 1:
            return 86.0
        case 2:
            return 55.0
        case 3:
            return 165.0
        default:
            return 50.0
            
        }
    }
    
    func saveAudioFile() {
        print(LoginHelper.getLoggedInUser())
        
        
//        // Get a reference to the storage service using the default Firebase App
//        let storage = Storage.storage()
//        // Create a root reference
//        let storageRef = storage.reference()
//
//
//        // This is equivalent to creating the full reference
//        let storagePath = "bamboomobile-9c643/images/space.jpg"
//        var audioRef = storage.reference(forURL: storagePath)
//
//
//
//        // File located on disk
//        let localFile = self.audioFile!
//
//
//        // Upload the file to the path "images/rivers.jpg"
//        let uploadTask = audioRef.putFile(from: localFile, metadata: nil) { metadata, error in
//            if let error = error {
//                // Uh-oh, an error occurred!
//            } else {
//                // Metadata contains file metadata such as size, content-type, and download URL.
//                let downloadURL = metadata!.downloadURL()
//            }
//        }
    }
    
        
}

extension VoiceMemoViewController: RecordCategoryTableViewCellProtocol {
    func sendCategory(category: Int) {
        //print(category)
    }
}

extension VoiceMemoViewController: RecordFileNamingTableViewCellProtocol {
    func doneButtonPressed() {
        print("done button pressed")
        //do checks for data
        self.saveAudioFile()
        
    }
    
    func sendFileName(name: String) {
        print(name)
    }
}

extension VoiceMemoViewController: RecordInputTableViewCellProtocol {
    func recordButtonPressed() {
        print("record button pressed")
    }
    
    func previewButtonPressed() {
        print("preview button pressed")
    }
    
    func sendRecordedFile(url:URL) {
        print("recorded File Function")
    }
}
