//
//  RecordCategoryTableViewCell.swift
//  BMH
//
//  Created by Robert Dates on 4/11/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit

protocol RecordCategoryTableViewCellProtocol: NSObjectProtocol {
    func redButtonPressed()
    func yellowButtonPressed()
    func greenButtonPressed()
}

class RecordCategoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var redButton: UIButton!
    @IBAction func redButtonAction(_ sender: Any) {
        guard self.delegate != nil else { return }
        self.delegate.redButtonPressed()
        
    }
    @IBOutlet weak var yellowButton: UIButton!
    @IBAction func yellowButtonAction(_ sender: Any) {
        guard self.delegate != nil else { return }
        self.delegate.yellowButtonPressed()
        
    }
    @IBOutlet weak var greenButton: UIButton!
    @IBAction func greenButtonAction(_ sender: Any) {
        guard self.delegate != nil else { return }
        self.delegate.greenButtonPressed()
        
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
