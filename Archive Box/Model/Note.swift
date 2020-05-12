//
//  Note.swift
//  BuxBox
//
//  Created by SongChiduk on 12/28/18.
//  Copyright © 2018 BuxBox. All rights reserved.
//

import Foundation
import ObjectMapper

class Note: Mappable {
    var noteId: String?
    var uniqueId: String?
    var bookId: String?
    var chapter: Int?
    var chapterTitle : String?
    var memo: String?
    var note: String?
    var isLiked: Bool?
    var isTapped : Bool = false
    
    init(chapter: Int?, chapterTitle: String?, memo: String?, note: String?, isLike: Bool?) {
        self.chapter = chapter
        self.chapterTitle = chapterTitle
        self.memo = memo
        self.note = note
        self.isLiked = isLike
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        noteId <- map["noteId"]
        uniqueId <- map["uniqueId"]
        bookId <- map["bookId"]
        chapter <- map["chapter"]
        memo <- map["memo"]
        note <- map["note"]
    }
    
    
}
