//
//  HistoryDataModel.swift
//  BuxBox
//
//  Created by Jiil Han on 01/04/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class HistoryDataModel : Mappable {

    
    var actionId: String?
    var action: String?
    var folderName: String?
    var folderID: String?
    var folderCreatedDate: String?
    var folderLastUpdate: String?
    var imageArrayForTesting : [UIImage]?
    var savingContentsImage : [String]?
    var contentData: [ContentData]?
    var savingcontentsText : String?
    var isFolder : Bool?
    var inputType : InputType?
    var hashTagArray : [String]?
    var deleteData: Bool = false
    var memo: String?
    var imageIdToEdit: String?
    var memoIdToEdit: String?
    
    var searchText : [String]?
    
    var urlImage : String?
    var urlTitle : String?
    var url : String?

    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        actionId <- map["actionId"]
        action <- map["action"]
        folderName <- map["folderName"]
        folderID <- map["folderId"]
        folderCreatedDate <- map["createdDate"]
        folderLastUpdate <- map["updatedDate"]
        savingContentsImage <- map["images"]
        contentData <- map["contentData"]
        memo <- map["memo"]
        url <- map["url"]
        hashTagArray <- map["hashTags"]
        
    }
    
    init() {
        
    }
    
//    init(name: String? = nil, id: String? = nil, createdDate: String? = nil, updatedDate: String? = nil, isFolder: Bool? = nil, image: [String]? = nil, text: String? = nil, inputType: InputType? = nil, testImageArray : [UIImage]? = nil, hashArray : [String]? = nil) {
//        self.folderName = name
//        self.folderID = id
//        self.folderCreatedDate = createdDate
//        self.folderLastUpdate = updatedDate
//        self.savingContentsImage = image
//        self.savingcontentsText = text
//        self.isFolder = isFolder
//        self.inputType = inputType
//        self.imageArrayForTesting = testImageArray
//        self.hashTagArray = hashArray
//    }
    
}

