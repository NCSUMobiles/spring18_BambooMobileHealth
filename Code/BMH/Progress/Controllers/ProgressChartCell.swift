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

    @IBOutlet weak var pieChartView : PieChartView!
    @IBOutlet weak var barChartView : BarChartView!
    @IBOutlet weak var iconImage : UIImageView!
    @IBOutlet weak var valueLabel : UILabel!
    @IBOutlet weak var iconLabel : UILabel!
    
    @IBOutlet weak var barChartToggle : UIButton!
    @IBOutlet weak var pieChartToggle : UIButton!
    
    @IBOutlet weak var chartToggleButton : UISegmentedControl!
    
    var progressValue : Int!
    var actEx : ActEx!
    
    var previousSegmentIndex : Int = -1
    var currentSegmentIndex : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        pieChartView.noDataText = "No data recorded so far."
        
        pieChartToggle.imageEdgeInsets = UIEdgeInsetsMake(2,2,2,2)
        pieChartToggle.backgroundColor = .clear
        pieChartToggle.layer.cornerRadius = 5
        pieChartToggle.layer.borderWidth = 1
        pieChartToggle.layer.borderColor = UIColor.darkGray.cgColor
        
        barChartToggle.imageEdgeInsets = UIEdgeInsetsMake(4,4,4,4)
        barChartToggle.backgroundColor = .clear
        barChartToggle.layer.cornerRadius = 5
        barChartToggle.layer.borderWidth = 1
        barChartToggle.layer.borderColor = UIColor.darkGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
