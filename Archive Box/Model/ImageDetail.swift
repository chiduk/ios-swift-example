//
//  ImageDetail.swift
//  Archive Box
//
//  Created by Jiil Han on 10/04/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import ObjectMapper

class Detail: Mappable{
    var date: String?
    var imageId: String?
    var imageName: String?
    var hashTags: [String]?
    var labels: [String]?
    var texts: [String]?
    var memo: [String]?
    var url: [String]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        date <- map["date"]
        imageId <- map["imageId"]
        imageName <- map["imageName"]
        hashTags <- map["hashTags"]
        labels <- map["labels"]
        texts <- map["texts"]
        memo <- map["memo"]
        url <- map["url"]
        
    }
    
    
}
