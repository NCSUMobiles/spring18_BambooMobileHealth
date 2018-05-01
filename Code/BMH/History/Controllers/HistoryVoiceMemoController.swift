//
//  HistoryVoiceMemoController.swift
//  BMH
//
//  Created by Otto on 4/21/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import Alamofire
import FirebaseAuth

protocol VoiceMemoAudioPlayerDelegate: class {
    func playAudioForCell(_ cell: HistoryVoiceMemoViewCell)
    func isPlaying() -> Bool
}

class HistoryVoiceMemoController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, VoiceMemoAudioPlayerDelegate {
    
    var memosArray : Array<VoiceMemo> = []
    var showPickerView : Bool = false
    var activities : [String]!
    var selectedActivity : Int = -1
    
    var selectionCellReuseIdentifer : String!
    var labelCellReuseIdentifer : String!
    var memoCellReuseIdentifer : String!

    var activityDebugLabel : String = ""

    var selectedAudioRow : Int = -1
    weak var isPlayingCell : HistoryVoiceMemoViewCell?
    //var audioPlayer: AVAudioPlayer?
    var updater : CADisplayLink! = nil
    
    var player : AVPlayer?
    var playerItem:AVPlayerItem?
    
    
    
    let activityView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // load the activity list and register custom nibs depending on the scene
        let dictionary = SettingsHelper.getActivityExerciseGoalValues()
        
        activities = []
        for pairArray in dictionary {
            for key in pairArray.keys {
                activities.append(key)
            }
        }
        activities.sort()
        
        if self.restorationIdentifier == "History_AudioViewController" {
            selectionCellReuseIdentifer = "History_AudioSelectionCell"
            memoCellReuseIdentifer = "History_AudioMemoViewCell"
            labelCellReuseIdentifer = "History_AudioViewCell"
            activityDebugLabel = "memo"
        }
        
        self.tableView.register(UINib(nibName:"HistoryMemoViewCell", bundle: nil), forCellReuseIdentifier: memoCellReuseIdentifer)
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
        
        //reloadVoiceMemos(activity: activities[0])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadVoiceMemos(activity: activities[0])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //reloadVoiceMemos(activity: activities[0])
    }
    
    fileprivate func updateRows(oldCount : Int) {
        var indexPaths : [IndexPath] = []
        
        self.tableView.beginUpdates()
        
        if (oldCount != 0) {
            // remove existing row
            for i in 0..<oldCount {
                indexPaths.append(IndexPath(row: i, section: 1))
            }
            self.tableView.deleteRows(at: indexPaths, with: .fade)
        }
        
        if (memosArray.count == 0 && oldCount != 0) {
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 2)], with: .fade)
        }
        else if memosArray.count != 0  {
            indexPaths = []
            for i in 0..<memosArray.count {
                indexPaths.append(IndexPath(row: i, section: 1))
            }
            self.tableView.insertRows(at: indexPaths, with: .fade)
            
            if (oldCount == 0) {
                self.tableView.deleteRows(at: [IndexPath(row: 0, section: 2)], with: .fade)
            }
        }
        self.tableView.endUpdates()
    }
    
    func reloadVoiceMemos(activity : String, _clearAll : Bool = true) {
        
        let oldCount = memosArray.count
        
        if _clearAll == true {
            memosArray.removeAll()
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
                              "name" : activity] as [String : Any]
                
                // make a request to API
                Alamofire.request(
                    URL(string: "http://" + (UIApplication.shared.delegate as! AppDelegate).serverIP + "/api/audio")!,
                    method: .get,
                    parameters: params)
                    .responseJSON { (response) -> Void in
                        let ret_code = response.response?.statusCode
                        if ret_code == 200 {
                            self.activityView.removeFromSuperview()
                            let json_res = (response.result.value as? [[String : Any]])!
                            
                            for res in json_res {
                                var memo = VoiceMemo()
                                memo.date = res["date"] as! String
                                memo.status = res["status"] as! String
                                memo.title = res["title"] as! String
                                memo.URL = res["URL"] as! String
                                memo.tags = res["tags"] as! [String : Bool]
                                
                                self.memosArray.append(memo)
                            }
                            
                            // remove all rows
                            self.updateRows(oldCount: oldCount)
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
                        else {
                            self.activityView.removeFromSuperview()
                            AlertHelper.showBasicAlertInVC(self, title: "Oops!", message: "Something went wrong. Could not retrieve data.")
                            self.activityView.removeFromSuperview()
                            
                            // remove all rows
                            self.updateRows(oldCount: oldCount)
                        }
                }
            }
            else {
                print("Error occurred in getting IDToken: \(String(describing: error))")
                // remove the spinner
                self.activityView.removeFromSuperview()
                AlertHelper.showBasicAlertInVC(self, title: "Oops!", message: "Something went wrong. Could not retrieve data.")
                
                // remove all rows
                self.updateRows(oldCount: oldCount)
            }
        })
        
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
        pickerLabel.text = activities[row]
        pickerLabel.font = labelRow?.textLabel?.font
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    // if select any row, force update the table view
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedActivity = row
        print("Selected \(activityDebugLabel) \"\(activities[selectedActivity])\"")
        
        // update the text in first section first row
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)))?.textLabel?.text = activities[selectedActivity]
        
        // stop existing audio
        stopAudio()
        
        reloadVoiceMemos(activity: activities[selectedActivity])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            if (self.showPickerView) {
                return 2
            }
            return 1
        }
        if section == 1 {
            return memosArray.count
        }
        if section == 2 {
            return memosArray.count == 0 ? 1 : 0;
        }
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == 0 && indexPath.row == 1) {
            cell.layoutSubviews()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1{
            return 160;
        }
        if indexPath.section == 1 {
            return 116;
        }
        return 44;
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell = .init()
        if (indexPath.section == 0 && indexPath.row == 1) {
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
            print("Selected \(activityDebugLabel) \"\(activities[selectedActivity])\"")
        }
        else if (indexPath.section == 0 && indexPath.row == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: labelCellReuseIdentifer, for: indexPath)
            if  selectedActivity == -1 {
                cell.textLabel?.text = activities[0]
            }
            else {
                cell.textLabel?.text = activities[selectedActivity]
            }
        }
        else if (indexPath.section == 1) {
            cell = tableView.dequeueReusableCell(withIdentifier: memoCellReuseIdentifer, for: indexPath)
            
            let voiceMemo = memosArray[indexPath.row]
            (cell as! HistoryVoiceMemoViewCell).populate(memo: voiceMemo)
            
            (cell as! HistoryVoiceMemoViewCell).setAudioTag(tag: indexPath.row + 500)
            
            (cell as! HistoryVoiceMemoViewCell).playerDelegate = self
            
        }
        else  if (indexPath.section == 2) {
            cell.textLabel?.text = "No recordings found!"
        }
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Choose a Tag"
        default:
            return ""
        }
    }
    
    // Set the section header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return CGFloat.leastNormalMagnitude
        }
        return tableView.sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        //        if section == 0 {
        //            return 2
        //        }
        return tableView.sectionFooterHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // dynamically insert or remove rows
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
            
            return
        }
      
        if self.selectedAudioRow == indexPath.row {
            return
        }
        
        self.stopAudio()
        //self.tableView.beginUpdates()
        self.selectedAudioRow = indexPath.row
        //self.tableView.endUpdates()
 
    }
    
    // MARK: IBActions
    @IBAction func stopAudio () {
        if let audioPlayer = player {
            if audioPlayer.rate != 0 {
                guard updater != nil else {
                    return
                }
                updater.invalidate()
                updater = nil
                audioPlayer.pause()
                isPlayingCell?.resetCell()
            }
        }
    }
    
    @IBAction func togglePlayAudio () {
        if let audioPlayer = player {
            if audioPlayer.rate != 0 {
                // was already playing, pause it
                audioPlayer.pause()
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
        if let audioPlayer = player {
            return audioPlayer.rate != 0
        }
        return false
    }
    
    func playAudioForCell(_ cell: HistoryVoiceMemoViewCell) {
        
        //let audioRow = cell.playButton.tag - 500;

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
        
        let url = cell.url

        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            /*
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            audioPlayer?.play()
            */
            playerItem = AVPlayerItem(url: url!)
            player = AVPlayer(playerItem: playerItem)
            player!.play()
            
            isPlayingCell = cell
            cell.playButton.setImage(UIImage.init(named: "pause"), for: .normal)
            updater = CADisplayLink(target: self, selector: #selector(updateAudioProgressView))
            updater.preferredFramesPerSecond = 1
            updater.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")

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
        if let audioPlayer = player, let isPlayingCell = isPlayingCell {
            
            isPlayingCell.timeSlider.minimumValue = 0.0
            isPlayingCell.timeSlider.maximumValue = Float(isPlayingCell.audioDuration)
            
            var current_time = 0
            var remaining_time = 0
            
            if player?.rate != 0
            {
                // Update progress
                
                isPlayingCell.timeSlider.setValue(Float(CMTimeGetSeconds(audioPlayer.currentTime())), animated: true)
                
                current_time = Int(CMTimeGetSeconds(audioPlayer.currentTime()))
                remaining_time = Int(isPlayingCell.audioDuration-Int(CMTimeGetSeconds(audioPlayer.currentTime())))
                
            }
            else {
                
                current_time = Int(CMTimeGetSeconds(audioPlayer.currentTime()))
                
                if (current_time == Int(isPlayingCell.audioDuration)) {
                    isPlayingCell.resetCell()
                    current_time = 0
                    remaining_time = Int(isPlayingCell.audioDuration)
                }
                else {
                    remaining_time = Int(isPlayingCell.audioDuration-Int(CMTimeGetSeconds(audioPlayer.currentTime())))
                }
            }
            
            isPlayingCell.playTime.text = String(format:"%02d", current_time/60) + ":" + String(format:"%02d", current_time%60)
            isPlayingCell.endTime.text = String(format:"%02d", remaining_time/60) + ":" + String(format:"%02d", remaining_time%60)
            isPlayingCell.timeSlider.setValue(Float(current_time), animated: true)
            
        }
    }
    
    
}
