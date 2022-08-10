//
//  File.swift
//  
//
//  Created by Sha Yan on 1/2/21.
//

import Foundation
import ArgumentParser
import ImageIO

struct IconResizeCommand: ParsableCommand {
    
    public static let configurations = CommandConfiguration(commandName: "icon", abstract: "Resize the given image to each platform required icon size")
    
    @Argument(help: "Directory of images or path of the image that you want to export them'\'it to the platform image sizes. The image(s) should be the biggest required size. ex: 3X for iOS xxxhdpi for android")
    private var fromURL: String
    
    @Option(name: .shortAndLong, help: "Which platform icons you want, can be [android] or [ios].")
    private var platform: String
    
    
    func run() throws {
        
        //check url is image or diractory
        let url = URL(fileURLWithPath: fromURL)
        
        //Create a dir (if not exists) for the images that about to resize
        let resizedDirURL = url.deletingPathExtension().deletingLastPathComponent().appendingPathComponent("Resized-iOS")
        try? FileManager.default.createDirectory(at: resizedDirURL, withIntermediateDirectories: true, attributes: nil)
        
        let imageName = url.deletingPathExtension().lastPathComponent
        guard let iconTemplate = IconTemplate(rawValue: platform) else {
            throw InvalidTemplate()
        }
        
        var divideInfo: [DivideImageInfo] {
            switch iconTemplate {
                /// android sizes
                /// https://developer.android.com/training/multiscreen/screendensities
            case .android:
                return [
                    DivideImageInfo(divideBy: 1, name: "\(imageName)xxxhdpi"),
                    DivideImageInfo(divideBy: 4/3, name: "\(imageName)xxhdpi"),
                    DivideImageInfo(divideBy: 2, name: "\(imageName)xhdpi"),
                    DivideImageInfo(divideBy: 8/3, name: "\(imageName)hdpi"),
                    DivideImageInfo(divideBy: 4, name: "\(imageName)xhdpi"),
                    DivideImageInfo(divideBy: 16/3, name: "\(imageName)lhdpi"),
                ]
            case .ios:
                return [
                    DivideImageInfo(divideBy: 1, name: "\(imageName)@3"),
                    DivideImageInfo(divideBy: 2, name: "\(imageName)@2"),
                    DivideImageInfo(divideBy: 3, name: "\(imageName)@1")
                ]
            }
        }
        
        try resize(dividedBy: divideInfo, imagesIn: url, saveTo: resizedDirURL)
        
    }
    
    func resize(dividedBy devides: [DivideImageInfo], imagesIn imagesURL: URL, saveTo saveDir: URL) throws {
        
        let url = imagesURL
        let acceptedImagePathExtensions = ImageFormat.allCases.map(\.pathString)
        
        let isURLForImage = acceptedImagePathExtensions.contains(url.pathExtension)
        let isURLForDirectory = url.pathExtension.isEmpty
        
        var imageURLs = [URL]()
        
        if isURLForImage {
            imageURLs = [url]
        }
        else if isURLForDirectory {
            imageURLs =
            try FileManager.default.contentsOfDirectory(
                at: url, includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles])
                .filter{acceptedImagePathExtensions.contains($0.pathExtension)}
            
        }else {
            throw(URLError.unvalidURL(path: url.path))
        }
        
        var errors = [Error]()
        
        for imageURL in imageURLs {
            let data = try Data(contentsOf: imageURL)
            let cfData = NSData(data: data) as CFData
            guard let source = CGImageSourceCreateWithData(cfData, nil) else {
                errors.append(URLError.unvalidImageData(path: imageURL.path))
                continue
            }
            
            let size = configureImageSize(atSource: source)
            
            for div in devides {
                let divSize = CGSize(width: size.width / div.divideBy, height: size.height / div.divideBy)
                guard let dividedImage = drawCGImageUsingCoreGraphic(fromSource: source, toSize: divSize) else {
                    errors.append(ResizeError(using: .usingCG))
                    continue
                }
                
                print("\(div.name): ", divSize)
                let imageDestinationURL = saveDir.appendingPathComponent(div.name).appendingPathExtension("png") as CFURL
                let imageDestination = CGImageDestinationCreateWithURL(imageDestinationURL, ImageFormat.png.cfsting, 1, nil)!
                CGImageDestinationAddImage(imageDestination, dividedImage, nil)
                CGImageDestinationFinalize(imageDestination)
            }
            
        }
    }
    
}

struct DivideImageInfo {
    let divideBy: CGFloat
    let name: String
}

fileprivate enum IconTemplate: String {
    case android = "android"
    case ios = "ios"
}

struct InvalidTemplate: Error {}
