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
    
}

class RecordInputTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBAction func recordButtonAction(_ sender: Any) {
        
    }
    @IBAction func previewButtonAction(_ sender: Any) {
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
