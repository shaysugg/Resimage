//
//  File.swift
//  
//
//  Created by Sha Yan on 9/19/20.
//

import ArgumentParser
import Foundation
import CoreGraphics
import Accelerate
import ImageIO


struct Resize: ParsableCommand {
    
    public static let configuration = CommandConfiguration(
        abstract: "Resize image based on given width or heigh.")
//
    @Argument(help: "URL of the image you want to resize.")
    private var fromURL: String
//
    @Option(name: .shortAndLong, help: "URL of place that you want to save the resized image.")
    private var storeTo: String?
    
    @Option(name: .long,
            help: "Resize width, Don't pass it if you want this to be calculate based on the height that you will pass.")
    private var width: Int?
    
    @Option(name: .long,
            help: "Resize height, Don't pass it if you want this to be calculate based on the width that you will pass.")
    private var height: Int?
    
    @Option(name: .shortAndLong, help: "Should pass png or jpg")
    private var format: String?
    
    
    
        
    func run() throws {
        
        // Creating Data from given URLpath
        let url = URL(fileURLWithPath: fromURL)
        guard let data = try? Data(contentsOf: url) else { throw ResizeError.unvalidURL}
        let imageCFData = NSData(data: data) as CFData

        
        
        // Read image width and height from it's file data info
        guard let source = CGImageSourceCreateWithData(imageCFData, nil) else { throw ResizeError.unvalidImageData}
        let deminsion = configureImageSize(atSource: source)
        let imageWidth = deminsion.width
        let imageHeight = deminsion.height
        
        // Calculate resize size
        var newSize: CGSize!
        
        
        if let unwrappedHeight = height, let unwrappedWidth = width {
            newSize = CGSize(width: unwrappedWidth, height: unwrappedHeight)
            
        }else if let unwrappedWidth = width {
            newSize = CGSize(width: Double(unwrappedWidth),
                             height: Double(imageHeight) * Double(unwrappedWidth) / Double(imageWidth))
            
        }else if let unwrappedHeight = height {
            newSize = CGSize(width: Double(imageWidth) * Double(unwrappedHeight) / Double(imageHeight),
                             height: Double(unwrappedHeight))
        }else {
            newSize = CGSize(width: imageWidth , height: imageHeight)
        }
        
        
        
        // Create a resized CGImage with calculated resize size
        // Since core graphic wont accepte both height and width, we use Accelerate in that case,
        // Otherwise we use Core Graphic because it's faster and safer.
        var resizedImage: CGImage!
        
        if width != nil && height != nil {
            do { try resizedImage = drawCGImageUsingAccelerate(fromSource: source, toSize: newSize) }
            catch let error { throw error }
        }else {
            resizedImage = drawCGImageUsingCoreGraphic(fromSource: source, toSize: newSize)
        }
        
        
        
        // Configure storeTo URL
        let storeToBaseURL = url.deletingLastPathComponent()
        
        let fileName = "resized-" + url.deletingPathExtension().lastPathComponent
        
        guard let imageFormat = format == nil ?
                ImageFormat(rawValue: url.pathExtension) :
            ImageFormat(rawValue: format!)
            else { throw ResizeError.unvalidImageFormat }
        
        
        
        let destenationURL = storeTo == nil ? storeToBaseURL.appendingPathComponent(fileName).appendingPathExtension(imageFormat.pathString):
            URL(fileURLWithPath: storeTo!)
        
        
        guard let destenation = CGImageDestinationCreateWithURL(destenationURL as CFURL, imageFormat.cfsting, 1, nil)
            else { throw ResizeError.unvalidStoreToPath }
        CGImageDestinationAddImage(destenation, resizedImage!, nil)
        CGImageDestinationFinalize(destenation)
        
        print(" ✔ Image successfully resized and saved to: \n",destenationURL)
    }
    
    
    
    
    
    
    
}
