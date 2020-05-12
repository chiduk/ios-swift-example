//
//  String.swift
//  BuxBox
//
//  Created by SongChiduk on 12/29/18.
//  Copyright © 2018 BuxBox. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    /// Percent escapes values to be added to a URL query as specified in RFC 3986
    ///
    /// This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// - returns: Returns percent-escaped string.
    
    func addingPercentEncodingForURLQueryValue() -> String? {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        
        return addingPercentEncoding(withAllowedCharacters: allowed)
    }
    
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
}

extension String{
    static func getParagraphHeight(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        
        return label.frame.height
    }
}

extension String {
    func guessLanguage() -> String {
        let length = self.utf16.count
        let languageCode = CFStringTokenizerCopyBestStringLanguage(self as CFString, CFRange(location: 0, length: length)) as String? ?? ""
        
        //        let locale = Locale(identifier: languageCode)
        return languageCode ?? "Unknown"
    }
    
    func isAlphanumeric() -> Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
        //        return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }
    
    func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
        if ignoreDiacritics {
            return self.range(of: "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$", options: .regularExpression) == nil && self != ""
        }
        else {
            return self.isAlphanumeric()
        }
    }
    
    func isItAlphabet() -> Bool{
        
        let textcount : Int = self.count
        var alphBetCount : Int = 0
        var nonAlphabetCount : Int = 0
        
        for char in self {
            let textVal = "\(String(char))"
            print("is alphabet ?? \(textVal.isAlphanumeric())")
            if String(char).isAlphanumeric() == true {
                alphBetCount += 1
            } else {
                nonAlphabetCount += 1
            }
        }
        
        var isAlphabetName : Bool?
        if alphBetCount > nonAlphabetCount {
            isAlphabetName = true
        } else {
            isAlphabetName = false
        }
        return isAlphabetName!
    }
    
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}
