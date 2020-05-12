//
//  BookNoteChapterModel.swift
//  BuxBox
//
//  Created by SongChiduk on 07/01/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation

class BookNoteChapterModel : NSObject {
    
    var chapter : String?
    var chapterTitle : String?
    var note : String?
    
    
    init(chapter : String, chapterTitle: String, note: String) {
        self.chapter = chapter
        self.chapterTitle = chapterTitle
        self.note = note
    }
    
}
