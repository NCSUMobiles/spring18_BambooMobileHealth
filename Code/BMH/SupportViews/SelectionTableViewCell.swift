//
//  SelectionTableViewCell.swift
//  BMH
//
//  Created by Kalpesh Padia on 3/28/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit

class SelectionTableViewCell: UITableViewCell {
    @IBOutlet weak var textField : UITextField!
    @IBOutlet weak var pickerView : UIPickerView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        textField.borderStyle = .none
//        textField.layer.backgroundColor = UIColor.white.cgColor
//        textField.layer.masksToBounds = false
//        textField.layer.shadowColor = UIColor.gray.cgColor
//        textField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
//        textField.layer.shadowOpacity = 1.0
//        textField.layer.shadowRadius = 0.0
        
        pickerView.layer.borderColor = UIColor.lightGray.cgColor
        pickerView.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
