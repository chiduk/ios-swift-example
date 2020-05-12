//
//  DBHelper.swift
//  BuxBox
//
//  Created by SongChiduk on 12/29/18.
//  Copyright © 2018 BuxBox. All rights reserved.
//

import Foundation
import SQLite

class DBHelper {
    
    let db = {() -> Connection in
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            
            return try Connection("\(path)/db.sqlite3")
        }catch{
            fatalError()
        }
    }
    
    let user = Table("user")
    let id = Expression<Int64>("id")
    let name = Expression<String?>("name")
    let uniqueId = Expression<String?>("uniqueId")
    let email = Expression<String?>("email")
    let phone = Expression<String?>("phone")
    let loggedin = Expression<Int64>("loggedin")
    
    let searchHistory = Table("search_history")
    let searchId = Expression<Int64>("id")
    let term = Expression<String?>("term")
    
    init() {
        
    }
    
    func insertSearchTerm( searchTerm: String){
        do{
            if(!tableExists(tableName: "search_history")){
                try db().run(searchHistory.create{ t in
                    t.column(searchId, primaryKey: true)
                    t.column(term)
                    
                })
            }
            
            let insert = searchHistory.insert(term <- searchTerm)
            let rowid = try db().run(insert)
            print(rowid)
        }catch{
            print(error)
        }
    }
    
    
    func deleteSearchTerm(searchTerm: String) {
        do{
            let query = searchHistory.filter( term == searchTerm)
            try db().run(query.delete())
        }catch{
            print(error)
        }
    }
    
    func deleteAllSearchTerm() -> Bool{
        do{
            
            let query = searchHistory.delete()
            
            if try db().run(query) > 0 {
                return true
            }
            else{
                return false
            }
        }catch{
            return false
        }
    }
    
    func getSearchTerms() -> [String]{
        let query = searchHistory.order(searchId.desc).limit(10)
        var terms = [String]()
        do{
            for row in try db().prepare(query){
                if let term = row[term]{
                    terms.append(term)
                }
            }
            
            
        }catch{
            print(error)
            
        }
        
        return terms
    }
    
    func insertUser(userUniqueId: String) {
        do{
            if(!tableExists(tableName: "user")){
                try db().run(user.create{ t in
                    t.column(id, primaryKey: true)
                    t.column(name)
                    t.column(uniqueId)
                    t.column(email)
                    t.column(phone)
                    t.column(loggedin)
                })
            }
            
            let insert = user.insert(uniqueId <- userUniqueId, loggedin <- 1)
            let rowid = try db().run(insert)
            print("Row ID: \(rowid)")
        }catch{
            print("DB insert error")
        }
    }
    
    func insertUser(userName: String, userUniqueId: String, userPhone: String, userEmail: String){
        do{
            if(!tableExists(tableName: "user")){
                try db().run(user.create{ t in
                    t.column(id, primaryKey: true)
                    t.column(name)
                    t.column(uniqueId)
                    t.column(email)
                    t.column(phone)
                    t.column(loggedin)
                })
            }
            
            let insert = user.insert(name <- userName, uniqueId <- userUniqueId, phone <- userPhone, email <- userEmail ,   loggedin <- 1)
            let rowid = try db().run(insert)
            print("Row ID: \(rowid)")
        }catch {
            print("DB insert error")
        }
    }
    
    func insertUser(userName: String, userUniqueId: String, userPhone: String){
        do{
            if(!tableExists(tableName: "user")){
                try db().run(user.create{ t in
                    t.column(id, primaryKey: true)
                    t.column(name)
                    t.column(uniqueId)
                    t.column(phone)
                    t.column(loggedin)
                })
            }
            
            let insert = user.insert(name <- userName, uniqueId <- userUniqueId, phone <- userPhone, loggedin <- 1)
            let rowid = try db().run(insert)
            print("Row ID: \(rowid)")
        }catch {
            print("DB insert error")
        }
    }
    
    func tableExists(tableName: String) -> Bool {
        do{
            let count:Int64 = try db().scalar("SELECT EXISTS(SELECT name FROM sqlite_master WHERE name = ?)", tableName) as! Int64
            
            if count>0{
                return true
            }
            else{
                return false
            }
            
        }catch{
            return false
        }
        
        
        
    }
    
    
    
    func deleteUser(){
        //let me = user.filter(id == 1)
        do{
            try db().run(user.drop())
            
        }catch{
            fatalError()
        }
    }
    
    func retrieveUserInfo() -> Bool{
        do {
            if let me = try db().pluck(user){

                
                guard let uniqueId = me[uniqueId] else {return false}
          
                JoinUserInfo.getInstance.uniqueId = uniqueId
                
                
                
            }
            
        }catch{
            
           
            fatalError()
            
        }
        
        return true
    }
    
    func retrievePhoneNumber() {
        do{
            if try columnExists(column: "phone", in: "user"){
                if let me = try db().pluck(user){
                    
                    if let phoneNumber = me[phone]{
                        JoinUserInfo.getInstance.phone = phoneNumber
                    }else{
                        JoinUserInfo.getInstance.phone = ""
                    }
                    
                }
            }else{
                try db().run(user.addColumn(phone))
                
                JoinUserInfo.getInstance.phone = ""
                let insert = user.insert( phone <- "", loggedin <- 1)
                let rowid = try db().run(insert)
                if let me = try db().pluck(user){
                    print(me)
                }
            }
        }catch{
            print(error)
        }
    }
    
    func addPhoneNumber(phoneNumber: String){
        do{
            if try columnExists(column: "phone", in: "user"){
                JoinUserInfo.getInstance.phone = phoneNumber
                
                let insert = user.insert( phone <- phoneNumber, loggedin <- 1)
                let rowid = try db().run(insert)
                if let me = try db().pluck(user){
                    print(me)
                }
            }else{
                try db().run(user.addColumn(phone))
                
                JoinUserInfo.getInstance.phone = ""
                let insert = user.insert( phone <- "", loggedin <- 1)
                let rowid = try db().run(insert)
                if let me = try db().pluck(user){
                    print(me)
                }
            }
        }catch{
            print(error)
        }
    }
    
    public func columnExists(column: String, in table: String) throws -> Bool {
        let stmt = try db().prepare("PRAGMA table_info(\(table))")
        
        let columnNames = stmt.makeIterator().map { (row) -> String in
            return row[1] as? String ?? ""
        }
        
        return columnNames.contains(where: { dbColumn -> Bool in
            return dbColumn.caseInsensitiveCompare(column) == ComparisonResult.orderedSame
        })
    }
    
    func isLoggedIn() -> Bool{
        do {
            if let me = try db().pluck(user) {
                if me[loggedin] == 1 {
                    return true
                }
                else{
                    return false
                }
            }
        }catch{
            
            return false
        }
        
        return false
    }
    
    
}
