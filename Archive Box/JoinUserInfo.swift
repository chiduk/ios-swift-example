//
//  JoinUserInfo.swift
//  BuxBox
//
//  Created by SongChiduk on 12/29/18.
//  Copyright © 2018 BuxBox. All rights reserved.
//

import Foundation

class JoinUserInfo {
    static let getInstance = JoinUserInfo()
    
    private var _name: String = ""
    private var _uniqueId: String = ""
    private var _email: String = ""
    private var _password: String = ""
    private var _phone: String = ""
    
    var name: String {
        get { return _name }
        set(n) {_name = n}
    }
    
    var uniqueId: String {
        get { return _uniqueId}
        set(u) {_uniqueId = u}
    }
    
    var email: String {
        get {return _email}
        set(e) {_email = e}
    }
    
    var password: String {
        get {return _password}
        set(p) {_password = password}
    }
    
    var phone: String {
        get {return _phone}
        set(p) {_phone = p}
    }
    
    
    
    
}
