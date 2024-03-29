//
//  File.swift
//  
//
//  Created by Sha Yan on 9/19/20.
//

import Foundation
import ArgumentParser
import CoreImage
import AVFoundation



struct CompressMultiple: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "compress",
        abstract: "Compress images that exist in a diractory")
    
    @Argument(help: "The directory that contains images you want to compress")
    private var imagesDirectoryPath: String
    
    @Option(name: .shortAndLong ,help: "Amount of Compression you want, Should be between 0 to 1.")
    private var compress: Float?
    
    @Option(name: .shortAndLong, help: "URL of the directory that you want to save compressed images.")
    private var storeTo: String?
    
    
    
    func run() throws {
        var errors = [Error]()
        
        // Check compress amount is valid
        guard let compress = compress,
              (0 ..< 1).contains(compress)
        else { throw CompressError.unvalidCompressSize(size: compress) }
        
        var compressAmount: CGFloat {
            if compress == 0 { return 0.001 }
            /// * this number configured by testing some pictures *
            return CGFloat(compress / 1.7 * 2)
        }
        
        
        // Turn all valid image paths to URLS
        let imageURLs =
            try FileManager.default.contentsOfDirectory(
                at: URL(fileURLWithPath: imagesDirectoryPath),
                includingPropertiesForKeys: nil,
                options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])
        
            .filter { (url) -> Bool in
                ImageFormat(rawValue: url.pathExtension.lowercased()) != nil
            }
        
        
        // Configure the URL that images need to be save there
        // Create if its not exist
        var destinationDirectoryURL: URL!
        if storeTo == nil {
            destinationDirectoryURL =
            URL(fileURLWithPath: imagesDirectoryPath)
                .appendingPathComponent("Resized", isDirectory: true)
            try? FileManager.default.createDirectory(
                at: destinationDirectoryURL,
                withIntermediateDirectories: true,
                attributes: nil)
            
        }else{
            destinationDirectoryURL = URL(fileURLWithPath: storeTo!)
        }
        
        
        
        // Start compressing and saving each image
        imageURLs.forEach { (url) in
            print("-> Compressing: ", url.lastPathComponent)
            
            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
                  let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
                      errors.append(URLError.unvalidImageData(path: url.path))
                return
            }
            
            // Configure image type
            // its better to use heic because it reduce file size significantly
            let imageType = ImageFormat(rawValue: url.pathExtension)!.cfsting
            
            // Configure parameters that needed to store image
            let destinationURL = destinationDirectoryURL.appendingPathComponent(url.lastPathComponent)
            let data = NSMutableData()
            
            guard let destination = CGImageDestinationCreateWithData(data, imageType, 1, nil)
            else {
                errors.append(URLError.unvalidImageData(path: url.path))
                return
            }
            
            let options: NSDictionary = [
                kCGImageDestinationLossyCompressionQuality: CGFloat(compressAmount) as CFNumber
            ]
            
            // Store image
            CGImageDestinationAddImage(destination, cgImage, options)
            CGImageDestinationFinalize(destination)
            
            
            do { try data.write(to: destinationURL, options: .atomic) }
            catch {
                errors.append(CompressError.writingCompressedImageData(path: destinationURL.path))
                return
            }
            
            print("-> Compressed!")
            
        }
        
        errors.isEmpty ?
            print(" ✔ All Files compressed successfully") :
            print(" ✘ errors: \(errors)")
    }
    
}

fileprivate enum CompressError: LocalizedError {
    case unvalidCompressSize(size: Float?)
    case writingCompressedImageData(path: String)
    
    var errorDescription: String? {
        switch self {
        case .unvalidCompressSize(let size?):
            return "\(size) is not a valid compress value, should be between 0 and 1."
        case .writingCompressedImageData(let path):
            return "Can't write data of image at \(path)"
        case .unvalidCompressSize(size: .none):
            return "Please provide a compress value."
        }
    }
}
