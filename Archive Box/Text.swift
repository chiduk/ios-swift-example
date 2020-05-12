//
//  Text.swift
//  BuxBox
//
//  Created by SongChiduk on 03/01/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit

class Text {
    static func textHeightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
    
    static func textHeightForTextView(text:String, name:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label = UITextView(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        
        label.translatesAutoresizingMaskIntoConstraints =  true
        label.isScrollEnabled = false
        label.font = font
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributedText = NSMutableAttributedString(string: text)
        
        let range = (text as NSString).range(of: name)
        attributedText.addAttributes ([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: text.count ))
        
        label.attributedText = attributedText
        
        
        label.sizeToFit()
        label.layoutIfNeeded()
        return label.frame.height
    }
    
    static func attributedTextHeightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.attributedText = text.htmlToAttributedString
        label.sizeToFit()
        
        return label.frame.height
    }
    
    
    
    static func textWidthForView(text:String, font:UIFont, height:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: height))
        label.numberOfLines = 1
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.width
    }
}
