//
//  HistoryMemoViewCell.swift
//  BMH
//
//  Created by Otto on 4/7/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import AVFoundation

class HistoryVoiceMemoViewCell: UITableViewCell {
  
    @IBOutlet weak var filename: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var tagLabel: UILabel!
    
    weak var playerDelegate : VoiceMemoAudioPlayerDelegate?
    var audioDuration : Int = 0
    var url : URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populate(memo : VoiceMemo) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .short
        outputFormatter.timeStyle = .short
        outputFormatter.doesRelativeDateFormatting = true
        
        url = URL(string: memo.URL)
        
        let audioAsset = AVURLAsset.init(url : url!, options: nil)
        audioDuration = Int(CMTimeGetSeconds(audioAsset.duration))
        
        filename.text = memo.title
        dateTime.text = outputFormatter.string(from: dateFormatter.date(from: memo.date)!)
        endTime.text = String(format:"%02d", audioDuration/60) + ":" + String(format:"%02d", audioDuration%60)
        tagLabel.text = memo.status
        
        resetCell()
    }
    
    func resetCell() {
        playButton.setImage(UIImage.init(named: "play"), for: .normal)
        playTime.text = "00:00"
        endTime.text = String(format:"%02d", audioDuration/60) + ":" + String(format:"%02d", audioDuration%60)
        timeSlider.maximumValue = Float(audioDuration)
        timeSlider.minimumValue = 0.0
        timeSlider.setValue(0.0, animated: false)
    }
    
    func setAudioTag(tag : Int) {
        playButton.tag = tag
    }
    
    @IBAction func playAudioForCell (button : UIButton) {
        playerDelegate?.playAudioForCell(self)
    }
    
}
