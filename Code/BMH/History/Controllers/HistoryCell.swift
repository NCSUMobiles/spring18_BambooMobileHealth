//
//  HistoryCell.swift
//  
//
//  Created by Yu-Ching Hu on 3/29/18.
//

import UIKit
import Charts

class HistoryCell: UITableViewCell {

    @IBOutlet weak var barChartView : BarChartView!
    @IBOutlet weak var aggSwitch : UISegmentedControl!
    @IBOutlet weak var leftButton : UIButton!
    @IBOutlet weak var rightButton : UIButton!
    @IBOutlet weak var topLabel : UILabel!
    @IBOutlet weak var aggLabel : UILabel!
    @IBOutlet weak var valueLabel : UILabel!
    @IBOutlet weak var unitsLabel : UILabel!
    @IBOutlet weak var bottomLabel : UILabel!
    
    var sumValue : Int!
    var actEx : ActEx!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        barChartView.noDataText = "No data found."
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
    
}
