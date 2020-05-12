//
//  FolderModel.swift
//  BuxBox
//
//  Created by SongChiduk on 07/02/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import ObjectMapper

class FolderModel : Mappable {
    
    
    
    var folderName : String?
    var folderImage : String?
    var folderID : String?
    var dateCreated : NSDate?
    var numberOfPeopleShared : Int?
    var isLocked : Bool = false
    var isForAddFolder : Bool = false
    var isOnDeleteMode : Bool = true
    
    init(id: String? = nil, imageName: String? = nil, name: String? = nil, numberOfShared: Int? = nil, locked: Bool? = nil, addFolder : Bool? = nil ) {
        self.folderImage = imageName
        self.folderName = name
        self.numberOfPeopleShared = numberOfShared
        self.folderID = id
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        folderName <- map["folderName"]
        folderID <- map["folderId"]
    }
}
