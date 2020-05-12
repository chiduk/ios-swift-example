//
//  Button.swift
//  BuxBox
//
//  Created by SongChiduk on 08/01/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit

class ButtonSelected : UIButton {
    
    var buttonSelected : Bool? {
        didSet{
            if buttonSelected == false {
                self.imageView?.tintColor = UIColor.lightGray
            } else {
                self.imageView?.tintColor = buxboxthemeColor
            }
        }
    }
    
    func changeColor() {
        buttonSelected = !buttonSelected!
    }
    
    
}

class SelectImageNextRightBar : UIBarButtonItem {
    
    var imageData : UIImage?
    
}

class CloseButton : UIButton {
    
    var id : String?
    
}

