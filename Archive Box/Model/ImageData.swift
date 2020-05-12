//
//  ImageData.swift
//  Archive Box
//
//  Created by Jiil Han on 18/04/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import ObjectMapper

class ImageData: Mappable {
    var imageName: String?
    var imageId: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        imageName <- map["imageName"]
        imageId <- map["imageId"]
    }
}
