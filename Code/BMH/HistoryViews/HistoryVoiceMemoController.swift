//
//  HistoryVoiceMemoController.swift
//  BMH
//
//  Created by Otto on 4/21/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import AVFoundation

protocol VoiceMemoAudioPlayerDelegate: class {
    func playAudioForCell(_ cell: HistoryVoiceMemoViewCell)
    func isPlaying() -> Bool
}

class HistoryVoiceMemoController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, VoiceMemoAudioPlayerDelegate {
    
    var memosArray : Array<VoiceMemo> = []
    var showPickerView : Bool = false
    var activities : [ActEx]!
    var selectedActivity : Int = -1
    
    var selectionCellReuseIdentifer : String!
    var memoCellReuseIdentifer : String!

    var activityDebugLabel : String = ""

    var selectedAudioRow : Int = -1
    weak var isPlayingCell : HistoryVoiceMemoViewCell?
    var audioPlayer: AVAudioPlayer?
    var updater : CADisplayLink! = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadVoiceMemos()
    }
    
    func reloadVoiceMemos(_clearAll : Bool = true) {
        
        // at some point load this from backend
        
        if _clearAll == true {
            memosArray.removeAll()
        }
        
        var voiceMemo = VoiceMemo.init()
        voiceMemo.title = "Cheerful"
        voiceMemo.fileName = Bundle.main.path(forResource: "bensound-ukulele", ofType: "mp3")!
        voiceMemo.date = Date.init().description
        voiceMemo.tags = "Tag 1, Tag 2, Tag 3"
        
        memosArray.append(voiceMemo)
        
        voiceMemo = VoiceMemo.init()
        voiceMemo.title = "Psychedelic"
        voiceMemo.fileName = Bundle.main.path(forResource: "bensound-dubstep", ofType: "mp3")!
        voiceMemo.date = Date.init().description
        voiceMemo.tags = "Tag 1, Tag 2, Tag 3"
        
        memosArray.append(voiceMemo)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopAudio()
    }
    
    // MARK: - Picker view data source and delegates
    // number of sections
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // number of items
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activities.count
//        return 0
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
        _ =  ((self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))) as! HistoryVoiceMemoViewCell)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // get the app delegate
        _ = UIApplication.shared.delegate as! AppDelegate
        
        // load the activity list and register custom nibs depending on the scene
        activities = []
        
        if self.restorationIdentifier == "History_AudioViewController" {
            selectionCellReuseIdentifer = "History_AudioSelectionCell"
            memoCellReuseIdentifer = "History_AudioViewCell"
            activityDebugLabel = "memo"
        }
        
        self.tableView.register(UINib(nibName:"HistoryMemoViewCell", bundle: nil), forCellReuseIdentifier: memoCellReuseIdentifer)
        self.tableView.register(UINib(nibName:"SelectionTableViewCell", bundle: nil), forCellReuseIdentifier: selectionCellReuseIdentifer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.showPickerView && section == 0 {
            return 2
        }
        return memosArray.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == 0 && indexPath.row == 1) {
            cell.layoutSubviews()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       if indexPath.section == 1 {
            return 116;
        }
        return 44;
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell = .init()
        if (indexPath.section == 0 && indexPath.row == 0) {
            // SOMETHING IS WRONG HERE
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
//            print("Selected \(activityDebugLabel) \"\(activities[selectedActivity].name)\"")
        }
        else if (indexPath.section == 1) {
            cell = tableView.dequeueReusableCell(withIdentifier: memoCellReuseIdentifer, for: indexPath)
            
            let voiceMemo = memosArray[indexPath.row]
            (cell as! HistoryVoiceMemoViewCell).populate(memo: voiceMemo)
            
            (cell as! HistoryVoiceMemoViewCell).setAudioTag(tag: indexPath.row + 500)
            
            (cell as! HistoryVoiceMemoViewCell).playerDelegate = self
            
        }
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 0) {
            return;
        }
        
        if self.selectedAudioRow == indexPath.row {
            return
        }
        
        self.stopAudio()
        self.tableView.beginUpdates()
        self.selectedAudioRow = indexPath.row
        self.tableView.endUpdates()
    }
    
    // MARK: IBActions
    @IBAction func stopAudio () {
        if let audioPlayer = audioPlayer {
            if audioPlayer.isPlaying {
                updater.invalidate()
                updater = nil
                audioPlayer.stop()
                isPlayingCell?.resetCell()
            }
        }
    }
    
    @IBAction func togglePlayAudio () {
        if let audioPlayer = audioPlayer {
            if audioPlayer.isPlaying {
                // was already playing, pause it
                audioPlayer.stop()
                isPlayingCell?.playButton.setImage(UIImage.init(named: "play"), for: .normal)
            }
            else {
                // was already paused, play it.
                isPlayingCell?.playButton.setImage(UIImage.init(named: "pause"), for: .normal)
                audioPlayer.play()
            }
        }
    }
    
    func isPlaying() -> Bool {
        if let audioPlayer = audioPlayer {
            return audioPlayer.isPlaying
        }
        return false
    }
    
    func playAudioForCell(_ cell: HistoryVoiceMemoViewCell) {
        
        let audioRow = cell.playButton.tag - 500;
        let audio = memosArray[audioRow]
        
        if isPlayingCell == cell {
            // existing cell
            //performSelector(onMainThread: #selector(self.updateAudioProgressView), with: nil, waitUntilDone: true)
            self.togglePlayAudio()
            return
        }
        
        // stop any existing audio
        self.stopAudio()
        isPlayingCell?.resetCell()
        isPlayingCell = nil
        
        var url : URL
        url = URL(fileURLWithPath: audio.fileName)

        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            isPlayingCell = cell
            cell.playButton.setImage(UIImage.init(named: "pause"), for: .normal)
            updater = CADisplayLink(target: self, selector: #selector(updateAudioProgressView))
            updater.preferredFramesPerSecond = 1
            updater.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        } catch {
            // couldn't load file :(
            let alert = UIAlertController.init(title: nil, message: "Couldn't play audio file.", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Okay",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @objc func updateAudioProgressView ()
    {
        if let audioPlayer = audioPlayer, let isPlayingCell = isPlayingCell {
            
            isPlayingCell.timeSlider.minimumValue = 0.0
            isPlayingCell.timeSlider.maximumValue = Float(audioPlayer.duration)
            
            var current_time = 0
            var remaining_time = 0
            
            if audioPlayer.isPlaying
            {
                // Update progress
                
                isPlayingCell.timeSlider.setValue(Float(audioPlayer.currentTime), animated: true)
                
                current_time = Int(audioPlayer.currentTime)
                remaining_time = Int(audioPlayer.duration-audioPlayer.currentTime)
                
            }
            else {
                // isPlayingCell.resetCell()
                // current_time = 0
                // remaining_time = Int(audioPlayer.duration)
                
                current_time = Int(audioPlayer.currentTime)
                remaining_time = Int(audioPlayer.duration-audioPlayer.currentTime)
            }
            
            isPlayingCell.playTime.text = String(format:"%02d", current_time/60) + ":" + String(format:"%02d", current_time%60)
            isPlayingCell.endTime.text = String(format:"%02d", remaining_time/60) + ":" + String(format:"%02d", remaining_time%60)
            isPlayingCell.timeSlider.setValue(Float(current_time), animated: true)
            
        }
    }
    
    
}
