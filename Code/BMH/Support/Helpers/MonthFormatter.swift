//
//  MonthFormatter.swift
//  BMH
//
//  Created by Otto on 4/20/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import Foundation
import Charts

class MonthFormatter: NSObject, IAxisValueFormatter {
    var dateLabel: [String] = []
    
    public override init() {
        for i in 1...31 {
            dateLabel.append(i.description)
        }
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateLabel[Int(value)]
    }
}
