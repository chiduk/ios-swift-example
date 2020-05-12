//
//  ContentData.swift
//  Archive Box
//
//  Created by Jiil Han on 16/04/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import ObjectMapper

class ContentData: Mappable {
    var imageId: String?
    var imageName: String?
    var memo: String?
    var memoId: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        imageId <- map["imageId"]
        imageName <- map["imageName"]
        memo <- map["memo"]
        memoId <- map["memoId"]
    }
    
    
}
