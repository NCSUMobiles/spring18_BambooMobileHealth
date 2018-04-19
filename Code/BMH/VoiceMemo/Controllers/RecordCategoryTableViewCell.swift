//
//  RecordCategoryTableViewCell.swift
//  BMH
//
//  Created by Robert Dates on 4/11/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit

protocol RecordCategoryTableViewCellProtocol: NSObjectProtocol {
    func sendCategory(category: Int)
}

class RecordCategoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var redButton: UIButton!{
        didSet{
            redButton.setImage(UIImage(named: "redOff"), for: .normal)
            redButton.setImage(UIImage(named: "red"), for: .selected)
        }
    }
    @IBAction func redButtonAction(_ sender: Any) {
        guard self.delegate != nil else { return }
        self.greenButton.isSelected = false
        self.redButton.isSelected = true
        self.yellowButton.isSelected = false
        self.delegate.sendCategory(category: 0)
        
    }
    @IBOutlet weak var yellowButton: UIButton! {
        didSet{
            yellowButton.setImage(UIImage(named: "yellowOff"), for: .normal)
            yellowButton.setImage(UIImage(named: "yellow"), for: .selected)
        }
    }
    @IBAction func yellowButtonAction(_ sender: Any) {
        guard self.delegate != nil else { return }
        self.greenButton.isSelected = false
        self.redButton.isSelected = false
        self.yellowButton.isSelected = true
        self.delegate.sendCategory(category: 1)
        
    }
    @IBOutlet weak var greenButton: UIButton!{
        didSet{
            greenButton.setImage(UIImage(named: "greenOff"), for: .normal)
            greenButton.setImage(UIImage(named: "green"), for: .selected)
        }
    }
    @IBAction func greenButtonAction(_ sender: Any) {
        guard self.delegate != nil else { return }
        self.greenButton.isSelected = true
        self.redButton.isSelected = false
        self.yellowButton.isSelected = false
        self.delegate.sendCategory(category: 2)
        
    }
    var delegate: RecordCategoryTableViewCellProtocol!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
