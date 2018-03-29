//
//  HistoryCell.swift
//  
//
//  Created by Otto on 3/29/18.
//

import UIKit
import Charts

class HistoryCell: UITableViewCell {

    @IBOutlet weak var barChartView : BarChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
