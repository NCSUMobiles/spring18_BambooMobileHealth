//
//  DayFormatter.swift
//  BMH
//
//  Created by Otto on 4/20/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import Foundation
import Charts

class DayFormatter: NSObject, IAxisValueFormatter{
    var hoursLabel = ["12A", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12P", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return hoursLabel[Int(value)]
    }
    

}
