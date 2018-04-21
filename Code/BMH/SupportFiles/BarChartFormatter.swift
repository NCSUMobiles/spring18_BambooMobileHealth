//
//  BarChartFormatter.swift
//  BMH
//
//  Created by Kalpesh Padia on 4/6/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import Foundation
import Charts

class BarChartFormatter: NSObject, IAxisValueFormatter{
    var daysOfWeek: [String]! = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return daysOfWeek[Int(value)]
    }
    
}
