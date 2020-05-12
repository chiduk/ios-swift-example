//
//  Book.swift
//  BuxBox
//
//  Created by SongChiduk on 12/28/18.
//  Copyright © 2018 BuxBox. All rights reserved.
//

import Foundation
import ObjectMapper

class Book : Mappable {
    var bookId: String?
    var uniqueId: String?
    var title: String?
    var author: String?
    var type: String?
    var coverImage: String?
    var genre: String?
    var datePurchased: String?
    var readingPeriod: String?
    var numberOfRead: Int?
    var rate: Double?
    
//    func runFakeData(image: String?, title: String?, author: String? ){
//        self.coverImage = image
//        self.title = title
//        self.author = author
//    }
    
    init(image: String?, title: String?, author: String?, genre : String?, datePurchased: String?, readingPeriod: String?, numberOfRead: Int?, rate: Double?) {
        self.coverImage = image
        self.title = title
        self.author = author
        self.genre = genre
        self.datePurchased = datePurchased
        self.readingPeriod = readingPeriod
        self.numberOfRead = numberOfRead
        self.rate = rate
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        bookId <- map["bookId"]
        uniqueId <- map["uniqueId"]
        title <- map["title"]
        author <- map["author"]
        type <- map["type"]
        coverImage <- map["coverImage"]
        genre <- map["genre"]
        datePurchased <- map["datePurchased"]
        readingPeriod <- map["readingPeriod"]
        numberOfRead <- map["numberOfRead"]
        rate <- map["rate"]
    }
    
    
}
