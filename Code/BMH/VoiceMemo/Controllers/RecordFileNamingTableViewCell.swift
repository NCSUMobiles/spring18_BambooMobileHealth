//
//  RecordFileNamingTableViewCell.swift
//  BMH
//
//  Created by Robert Dates on 4/11/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit

protocol RecordFileNamingTableViewCellProtocol: NSObjectProtocol {
    func doneButtonPressed()
    func sendFileName()
}

class RecordFileNamingTableViewCell: UITableViewCell {

    @IBOutlet weak var fileNameTextField: UITextField!
    
    @IBAction func voiceButtonAction(_ sender: Any) {
    }
    @IBAction func doneButtonAction(_ sender: Any) {
    }
    
    var delegate:RecordFileNamingTableViewCellProtocol!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
