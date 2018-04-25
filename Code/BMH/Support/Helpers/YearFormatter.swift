//
//  YearFormatter.swift
//  BMH
//
//  Created by Otto on 4/20/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import Foundation
import Charts

class YearFormatter: NSObject, IAxisValueFormatter {
    var monthLabel: [String]! = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return monthLabel[Int(value)]
    }
}
