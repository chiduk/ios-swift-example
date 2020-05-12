//
//  TapGestureRecognizer.swift
//  BuxBox
//
//  Created by SongChiduk on 29/03/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit

class CustomTapGestureRecognizer : UITapGestureRecognizer {
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    var index : Int?
    var data : PhotoDataModel?
    var historyData : HistoryDataModel?
}
