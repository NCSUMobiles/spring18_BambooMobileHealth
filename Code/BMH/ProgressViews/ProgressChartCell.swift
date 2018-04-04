//
//  ProgressChartCell.swift
//  BMH
//
//  Created by Kalpesh Padia on 4/1/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import Charts

class ProgressChartCell: UITableViewCell {

    @IBOutlet weak var chartView : PieChartView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    
    var progressValue : Int!
    var actEx : ActEx!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        chartView.noDataText = "No data recorded so far."
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
