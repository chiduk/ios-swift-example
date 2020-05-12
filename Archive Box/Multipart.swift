//
//  Multipart.swift
//  BuxBox
//
//  Created by SongChiduk on 1/3/19.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices


func createImageUploadRequest(url: String, parameters: [String: Any], images: [UIImage]) throws -> URLRequest {
    
    let boundary = generateBoundaryString()
    
    let url = URL(string:url)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    request.httpBody = try createBody(with: parameters, filePathKey: "file", images: images,  boundary: boundary)
    
    return request
}

func createProfileImageUploadRequest(url: String, parameters: [String:Any], uniqueId: String, image: UIImage) throws -> URLRequest {
    let boundary = generateBoundaryString()
    
    let url = URL(string:url)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    var body = Data()
    
    for (key, value) in parameters {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }
    
    let imageData = image.jpegData(compressionQuality: 1.0)
    let mimeType = "image/jpg"
    
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"profile\"; filename=\"\(uniqueId).jpg\"\r\n")
    body.append("Content-Type: \(mimeType)\r\n\r\n")
    body.append(imageData!)
    body.append("\r\n")
    body.append("--\(boundary)--\r\n")
    request.httpBody = body
    
    return request
}

/// Create body of the `multipart/form-data` request
///
/// - parameter parameters:   The optional dictionary containing keys and values to be passed to web service
/// - parameter filePathKey:  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
/// - parameter paths:        The optional array of file paths of the files to be uploaded
/// - parameter boundary:     The `multipart/form-data` boundary
///
/// - returns:                The `Data` of the body of the request

private func createBody(with parameters: [String: Any]?, filePathKey: String, images:[UIImage], boundary: String) throws -> Data {
    var body = Data()
    
    if parameters != nil {
        for (key, value) in parameters! {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
    }
    
    for index in 0 ..< images.count {
        let imageData = images[index].jpegData(compressionQuality: 0.7)
        let mimeType = "image/jpg"
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"file\(index)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(imageData!)
        body.append("\r\n")
    }
    
    body.append("--\(boundary)--\r\n")
    return body
}

/// Create boundary string for multipart/form-data request
///
/// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.

private func generateBoundaryString() -> String {
    return "Boundary-\(UUID().uuidString)"
}

/// Determine mime type on the basis of extension of a file.
///
/// This requires `import MobileCoreServices`.
///
/// - parameter path:         The path of the file for which we are going to determine the mime type.
///
/// - returns:                Returns the mime type if successful. Returns `application/octet-stream` if unable to determine mime type.

private func mimeType(for path: String) -> String {
    let url = URL(fileURLWithPath: path)
    let pathExtension = url.pathExtension
    
    if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
        if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mimetype as String
        }
    }
    return "application/octet-stream"
}

extension Data {
    
    /// Append string to Data
    ///
    /// Rather than littering my code with calls to `data(using: .utf8)` to convert `String` values to `Data`, this wraps it in a nice convenient little extension to Data. This defaults to converting using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `Data`.
    
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
