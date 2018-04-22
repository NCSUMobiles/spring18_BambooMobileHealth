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
    var hoursLabel = ["12A", "1A", "2A", "3A", "4A", "5A", "6A", "7A", "8A", "9A", "10A", "11A", "12P", "1P", "2P", "3P", "4P", "5P", "6P", "7P", "8P", "9P", "10P", "11P"]
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return hoursLabel[Int(value)]
    }
    

}
