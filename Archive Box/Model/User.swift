//
//  User.swift
//  BuxBox
//
//  Created by SongChiduk on 12/28/18.
//  Copyright © 2018 BuxBox. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {
    var uniqueId: String?
    var name: String?
    var facebookId: String?
    var status: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        uniqueId <- map["uniqueId"]
        name <- map["name"]
        facebookId <- map["facebookId"]
        status <- map["status"]
    }
    
    
}
