//
//  SelectionTableViewCell.swift
//  BMH
//
//  Created by Kalpesh Padia on 3/28/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit

class SelectionTableViewCell: UITableViewCell {
    @IBOutlet weak var pickerView : UIPickerView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        pickerView.selectRow(0, inComponent: 0, animated: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
