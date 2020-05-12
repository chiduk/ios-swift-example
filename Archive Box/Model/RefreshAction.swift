//
//  RefreshAction.swift
//  Archive Box
//
//  Created by Jiil Han on 16/04/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit

class RefreshAction {
    var action: String?
    var actionId: String?
    var deleteAction: Bool?
    var imageIds: [String]?
    var memoId: String?
    var images: [ImageData]?
    
    var convertToImage: Bool = false
    init() {
        
    }
    
    init(action: String, actionId: String, deleteAction: Bool) {
        self.action = action
        self.actionId = actionId
        self.deleteAction = deleteAction
    }
    
    init( actionId: String, deleteAction: Bool) {
  
        self.actionId = actionId
        self.deleteAction = deleteAction
    }
    
    init( actionId: String, deleteAction: Bool, imageIds: [String]) {
        
        self.actionId = actionId
        self.deleteAction = deleteAction
        self.imageIds = imageIds
    }
    
    init( actionId: String, deleteAction: Bool, images: [ImageData]){
        self.actionId = actionId
        self.deleteAction = deleteAction
        self.images = images
    }
    
    init( actionId: String, deleteAction: Bool, memoId: String) {
        
        self.actionId = actionId
        self.deleteAction = deleteAction
        self.memoId = memoId
    }
}
