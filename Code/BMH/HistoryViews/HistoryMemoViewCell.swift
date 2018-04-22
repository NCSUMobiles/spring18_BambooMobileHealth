//
//  HistoryMemoViewCell.swift
//  BMH
//
//  Created by Otto on 4/7/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit

class HistoryMemoViewCell: UITableViewCell {
  
    @IBOutlet weak var filename: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var remainTime: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
