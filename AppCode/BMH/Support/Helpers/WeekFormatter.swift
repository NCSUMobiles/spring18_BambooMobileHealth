//
//  WeekFormatter.swift
//  BMH
//
//  Created by Otto on 4/20/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import Foundation
import Charts

class WeekFormatter: NSObject, IAxisValueFormatter {
    var weekLabel: [String]! = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return weekLabel[Int(value)]
    }
}
