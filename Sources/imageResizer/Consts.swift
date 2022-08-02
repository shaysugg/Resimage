//
//  File.swift
//  
//
//  Created by Sha Yan on 10/1/20.
//

import Foundation

enum ResizeError: Error {
    case unvalidURL
    case unvalidStoreToPath
    case unvalidImageData
    case unvalidImageFormat
    case unvalidGivenSize
    case bufferingError
    
}

enum CompressError: Error {
    case unvalidCompressSize
    case unvalidGivenURL
    case unvalidImageData
    case writingCompressedImageData
}


enum ImageFormat: String {
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
