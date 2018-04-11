//
//  RecordInputTableViewCell.swift
//  BMH
//
//  Created by Robert Dates on 4/11/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
protocol RecordInputTableViewCellProtocol: NSObjectProtocol {
    func recordButtonPressed()
    func previewButtonPressed()
    func sendRecordedFile()
    
}

class RecordInputTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBAction func recordButtonAction(_ sender: Any) {
        guard self.delegate != nil else { return }
        
    }
    @IBAction func previewButtonAction(_ sender: Any) {
        guard self.delegate != nil else { return }
    }
    
    var delegate:RecordInputTableViewCellProtocol!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
