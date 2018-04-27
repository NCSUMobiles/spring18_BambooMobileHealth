//
//  RecordInputTableViewCell.swift
//  BMH
//
//  Created by Robert Dates on 4/11/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import AVFoundation

protocol RecordInputTableViewCellProtocol: NSObjectProtocol {
    func recordButtonPressed()
    func previewButtonPressed()
    func sendRecordedFile(url:URL)
    
}

class RecordInputTableViewCell: UITableViewCell, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    
    @IBOutlet weak var timeLabel: UILabel! {
        didSet{
            
        }
    }
    @IBOutlet weak var recordedLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton! {
        didSet{
            recordButton.setImage(UIImage(named: "stopRecordButton"), for: UIControlState.selected)
            recordButton.setImage(UIImage(named: "recordButton"), for: UIControlState.normal)
        }
    }
    @IBOutlet weak var previewButton: UIButton! {
        didSet{
            previewButton.isEnabled = false
            previewButton.setImage(UIImage(named: "stopReviewButton"), for: .selected)
            previewButton.setImage(UIImage(named: "playReviewButton"), for: .normal)

        }
    }
    @IBAction func recordButtonAction(_ sender: Any) {
        guard self.delegate != nil else { return }
        recordTapped()
        
    }
    @IBAction func previewButtonAction(_ sender: Any) {
        guard self.delegate != nil else { return }
        if(self.previewButton.isEnabled && self.previewButton.isSelected){
            //stop audio
            self.previewButton.isSelected = false
            self.stopPreview()
        }else if(self.previewButton.isEnabled && !self.previewButton.isSelected) {
            //play audio
            self.previewButton.isSelected = true
            self.playPreview()
        }
    }
    //MARK: Properties
    var delegate:RecordInputTableViewCellProtocol!
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var audioFileURL:URL!
    
    var seconds = 60
    var timer = Timer()
    var isTimerRunning = false
    
    func startRecording() {
        guard recordingSession != nil else { return }

        audioFileURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            guard audioRecorder != nil else { return }
            audioRecorder!.delegate = self
            let min:TimeInterval = 60
            audioRecorder!.record(forDuration: min)
            
            
            //recordButton.setTitle("Tap to Stop", for: .normal)
           
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        guard audioRecorder != nil else { return }
        guard recordingSession != nil else { return }
        
        audioRecorder!.stop()
        audioRecorder = nil
        
        if success {
            timer.invalidate()
            self.recordButton.isSelected = false
            self.previewButton.isEnabled = true
            guard delegate != nil else { return }
            delegate.sendRecordedFile(url: self.audioFileURL)
            
        } else {
            self.previewButton.isEnabled = false
        }
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            self.recordButton.isSelected = true
            startRecording()
            runTimer()
            seconds = 60
            timeLabel.text = timeString(time: TimeInterval(seconds))
            recordedLabel.text = timeString(time: TimeInterval(0))
        } else {
            recordedLabel.text = timeString(time: TimeInterval(-(seconds - 60)))
            timeLabel.text = timeString(time: TimeInterval(0))
            finishRecording(success: true)
        }
    }
    
    func playPreview() {
       // let path = Bundle.main.path(forResource: "recording.m4a", ofType:nil)!
        let url = audioFileURL
        guard url != nil else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch {
            // couldn't load file :(
            
        }
    }
    
    func stopPreview() {
        audioPlayer?.stop()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
      
        if !flag {
            finishRecording(success: false)
        }else {
            finishRecording(success: true)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.previewButton.isSelected = false
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            //Send alert to indicate "time's up!"
        } else {
            seconds -= 1
            timeLabel.text = timeString(time: TimeInterval(seconds))
            recordedLabel.text = timeString(time: TimeInterval((60 - seconds)))
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
