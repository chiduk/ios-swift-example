//
//  Constants.swift
//  BuxBox
//
//  Created by SongChiduk on 12/28/18.
//  Copyright © 2018 BuxBox. All rights reserved.
//

import Foundation
import UIKit

struct Constants{
    #if DEBUG
    
    static let appServerHost = "http://10.3.2.6:8080"
    
    
    #else
    static let appServerHost = "http://10.3.2.6"
    #endif
}

public let marginBase: CGFloat = 8
public let buxboxthemeColor = Color.hexStringToUIColor(hex: "#293E55")

struct RestApi {
    static let user = "/user"
    static let login = Constants.appServerHost + RestApi.user + "/logIn"
    static let register = Constants.appServerHost + RestApi.user + "/register"
    static let facebookLogin = Constants.appServerHost + RestApi.user + "/facebookLogIn"

    static let home = "/home"
    static let getList = Constants.appServerHost + RestApi.home + "/getList"
    static let getAction = Constants.appServerHost + RestApi.home + "/getAction"
    static let deleteAction = Constants.appServerHost + RestApi.home + "/deleteAction"
    
    static let note = "/n"
    static let addNoteImage = Constants.appServerHost + RestApi.note + "/addNoteImage"
    static let addNote = Constants.appServerHost + RestApi.note + "/addNote"
    static let getNote = Constants.appServerHost + RestApi.note + "/getNote"
    static let getFolders = Constants.appServerHost + RestApi.note + "/getFolders"
    static let getImageDetail = Constants.appServerHost + RestApi.note + "/getImageDetail"
    static let getNoteDetail = Constants.appServerHost + RestApi.note + "/getNoteDetail"
    static let deleteImage = Constants.appServerHost + RestApi.note + "/deleteImage"
    static let deleteNote = Constants.appServerHost + RestApi.note + "/deleteNote"
    static let deleteAllImages = Constants.appServerHost + RestApi.note + "/deleteAllImages"
    static let deleteAllNotes = Constants.appServerHost + RestApi.note + "/deleteAllNotes"
    static let moveImage = Constants.appServerHost + RestApi.note + "/moveImage"
    static let moveNote = Constants.appServerHost + RestApi.note + "/moveNote"
    //static let deleteAction = Constants.appServerHost + RestApi.note + "/deleteAction"
    static let saveImageDetail = Constants.appServerHost + RestApi.note + "/saveImageDetail"
    static let saveNoteDetail = Constants.appServerHost + RestApi.note + "/saveNoteDetail"
    static let saveHashTags = Constants.appServerHost + RestApi.note + "/saveHashTags"
    static let saveMemo = Constants.appServerHost + RestApi.note + "/saveMemo"
    static let saveUrl = Constants.appServerHost + RestApi.note + "/saveUrl"
    static let saveLabels = Constants.appServerHost + RestApi.note + "/saveLabels"
    static let saveFullText = Constants.appServerHost + RestApi.note + "/saveFullText"
    static let getFolderContent = Constants.appServerHost + RestApi.note + "/getFolderContent"
    static let getContent = Constants.appServerHost + RestApi.note + "/getContent"
    
    static let folder = "/folder"
    static let deleteFolder = Constants.appServerHost + RestApi.folder + "/deleteFolder"
    static let createFolder = Constants.appServerHost + RestApi.folder + "/createFolder"
    static let renameFolder = Constants.appServerHost + RestApi.folder + "/renameFolder"
    static let checkFolderName = Constants.appServerHost + RestApi.folder + "/checkFolderName"
    
    static let search = "/search"
    static let searchKeyword = Constants.appServerHost + RestApi.search + "/searchKeyword"
    
    
    static let noteImage = Constants.appServerHost + "/note/"
}
