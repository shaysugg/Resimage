//
//  File.swift
//  
//
//  Created by Sha Yan on 5/11/1401 AP.
//

import Foundation
import ImageIO
import Accelerate

func configureImageSize(atSource source: CGImageSource) -> CGSize {
    let imageproperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)! as NSDictionary
    let imageHeight = imageproperties["PixelHeight"] as! Int
    let imageWidth = imageproperties["PixelWidth"] as! Int
    return CGSize(width: imageWidth, height: imageHeight)
}


func drawCGImageUsingAccelerate(fromSource source: CGImageSource, toSize size: CGSize) throws -> CGImage {
    // Create CGImage From Data
        guard let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil),
        let colorSpace = cgImage.colorSpace
    else {throw ResizeError.unvalidImageData}
    
    // Create a source buffer
    var format = vImage_CGImageFormat(bitsPerComponent: numericCast(cgImage.bitsPerComponent),
                                      bitsPerPixel: numericCast(cgImage.bitsPerPixel),
                                      colorSpace: Unmanaged.passUnretained(colorSpace),
                                      bitmapInfo: cgImage.bitmapInfo,
                                      version: 0,
                                      decode: nil,
                                      renderingIntent: .absoluteColorimetric)
    
    var sourceBuffer = vImage_Buffer()
    
    var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
    guard error == kvImageNoError else { throw ResizeError.bufferingError }
    
    let bytesPerPixel = cgImage.bitsPerPixel
    let destBytesPerRow = Int(size.width) * bytesPerPixel
    let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(size.height) * destBytesPerRow)
    defer {
        destData.deallocate()
    }
    var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(Int(size.height)), width: vImagePixelCount(Int(size.width)), rowBytes: destBytesPerRow)
    
    
    // Scale the image
    error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
    guard error == kvImageNoError else { throw ResizeError.bufferingError }

    // Create a CGImage from vImage_Buffer
    guard let destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue() else { throw ResizeError.bufferingError }
    guard error == kvImageNoError else { throw ResizeError.bufferingError }
    
    return destCGImage
    
}




func drawCGImageUsingCoreGraphic(fromSource source: CGImageSource, toSize size: CGSize) -> CGImage? {
    let options = [
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
        ] as CFDictionary
    
    return CGImageSourceCreateThumbnailAtIndex(source, 0, options)
}
