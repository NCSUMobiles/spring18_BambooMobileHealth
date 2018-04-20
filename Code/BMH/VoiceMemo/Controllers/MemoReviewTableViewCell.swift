//
//  MemoReviewTableViewCell.swift
//  BMH
//
//  Created by Robert Dates on 4/11/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit

class MemoReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var trash: UIButton!
    @IBAction func trashAction(_ sender: Any) {
    }
    @IBOutlet weak var playButton: UIButton!
    @IBAction func playButtonAction(_ sender: Any) {
    }
    
    var index:IndexPath!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

