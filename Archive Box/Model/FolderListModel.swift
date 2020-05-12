//
//  FolderListModel.swift
//  BuxBox
//
//  Created by Jiil Han on 18/03/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import ObjectMapper

class FolderListModel : Mappable {
    
    var folderName: String?
    var folderID: String?
    var folderCreatedDate: String?
    var folderLastUpdate: String?
    var savingContentsImage : UIImage?
    var savingcontentsText : String?
    var isFolder : Bool?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        folderName <- map["folderName"]
        folderID <- map["folderId"]
        folderCreatedDate <- map["createdDate"]
        folderLastUpdate <- map["updatedDate"]
    }
    
    init(name: String, id: String, createdDate: String, updatedDate: String, image: UIImage? = nil, text: String? = nil, isFolder: Bool? = nil) {
        self.folderName = name
        self.folderID = id
        self.folderCreatedDate = createdDate
        self.folderLastUpdate = updatedDate
        self.savingContentsImage = image
        self.savingcontentsText = text
        self.isFolder = isFolder
    }
    
}
