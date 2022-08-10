//
//  File.swift
//  
//
//  Created by Sha Yan on 10/1/20.
//

import Foundation

enum URLError: LocalizedError {
    case unvalidURL(path: String)
    case unvalidStoreToPath(path: String)
    case unvalidImageData(path: String)
    case unvalidImageFormat(format: String?)
    
    
    var errorDescription: String? {
        switch self {
        case .unvalidURL(let url):
            return "\(url) is not a valid URL"
        case .unvalidStoreToPath(let path):
            return "\(path) is not a valid URL"
        case .unvalidImageData(let path):
            return "The data at \(path) is not valid image data"
        case .unvalidImageFormat(let format):
            return "The format: \(format) is not supported"
        }
    }
}

struct ResizeError: LocalizedError {
    enum Using {
    case usingAccelerate
    case usingCG
    }
    
    let using: Using
    
    var errorDescription: String? {
        return "An error happend while resizing the image"
    }
}



enum ImageFormat: String, CaseIterable {
    case jpg = "jpg"
    case jpeg = "jpeg"
    case png = "png"
    
    var pathString: String {
        return self.rawValue
    }
    
    var cfsting: CFString {
        switch self {
        case .jpg: return kUTTypeJPEG
        case .png: return kUTTypePNG
        case .jpeg: return kUTTypeJPEG
        }
    }
}
