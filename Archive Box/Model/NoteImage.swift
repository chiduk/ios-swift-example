//
//  NoteImage.swift
//  BuxBox
//
//  Created by SongChiduk on 12/28/18.
//  Copyright © 2018 BuxBox. All rights reserved.
//

import Foundation
import ObjectMapper

class NoteImage : Mappable {
    var imageId: String?
    var uniqueId: String?
    var bookId: String?
    var imageName: String?
    var chapter: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        imageId <- map["imageId"]
        uniqueId <- map["uniqueId"]
        bookId <- map["bookId"]
        imageName <- map["imageName"]
        chapter <- map["chapter"]
    }
    
    
}
