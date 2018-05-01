//
//  VoiceMemo.swift
//  BMH
//
//  Created by Kalpesh Padia on 4/23/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import Foundation

struct VoiceMemo : Codable {
    
    var title : String
    var URL : String
    var date : String
    var status : String
    var tags : [String : Bool]
    
    init() {
        title = ""
        date = ""
        URL = ""
        status = ""
        tags = [String: Bool]()
    }
}
