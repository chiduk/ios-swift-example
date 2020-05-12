//
//  String.swift
//  BuxBox
//
//  Created by SongChiduk on 08/01/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit

func getRangeOfSubString(subString: String, fromString: String) -> NSRange {
    let sampleLinkRange = fromString.range(of: subString)!
    let startPos = fromString.distance(from: fromString.startIndex, to: sampleLinkRange.lowerBound)
    let endPos = fromString.distance(from: fromString.startIndex, to: sampleLinkRange.upperBound)
    let linkRange = NSMakeRange(startPos, endPos - startPos)
    return linkRange
}

func getToday() -> String {
    let date = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
    
    let year =  components.year
    let month = components.month
    let day = components.day
    
    var weekday : String?
    if components.weekday == 1 {
        weekday = "Sunday"
    } else if components.weekday == 2 {
        weekday = "Monday"
    } else if components.weekday == 3 {
        weekday = "Tuesday"
    } else if components.weekday == 4 {
        weekday = "Wednesday"
    } else if components.weekday == 5 {
        weekday = "Thursday"
    } else if components.weekday == 6 {
        weekday = "Friday"
    } else if components.weekday == 7 {
        weekday = "Saturday"
    }
    
    return "\(year!)-\(month!)-\(day!)-\(String(describing: weekday!))"
    
}
