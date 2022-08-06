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
    
    public static let configurations = CommandConfiguration(commandName: "icon", abstract: "Resize 3X image(s) to 2X and 1X")
    
    @Argument(help: "Directory of pictures or path of a picture that you want to export them'\'it to iOS image sizes.")
    private var fromURL: String
    
    @Option(name: .shortAndLong, help: "template")
    private var template: String
    
    
    func run() throws {
        
        //check url is image or diractory
        let url = URL(fileURLWithPath: fromURL)
        
        //Create a dir (if not exists) for the images that about to resize
        let resizedDirURL = url.deletingPathExtension().deletingLastPathComponent().appendingPathComponent("Resized-iOS")
        try? FileManager.default.createDirectory(at: resizedDirURL, withIntermediateDirectories: true, attributes: nil)
        
        let imageName = url.deletingPathExtension().lastPathComponent
        guard let iconTemplate = IconTemplate(rawValue: template) else {
            throw InvalidTemplate()
        }
        
        var divideInfo: [DivideImagInfo] {
            switch iconTemplate {
            case .android:
                return [
                    DivideImagInfo(divideBy: 1, name: "\(imageName)@3"),
                    DivideImagInfo(divideBy: 2, name: "\(imageName)@2"),
                    DivideImagInfo(divideBy: 3, name: "\(imageName)@1")
                ]
            case .ios:
                return [
                    DivideImagInfo(divideBy: 1, name: "\(imageName)@3"),
                    DivideImagInfo(divideBy: 2, name: "\(imageName)@2"),
                    DivideImagInfo(divideBy: 3, name: "\(imageName)@1")
                ]
            }
        }
        
        try resize(dividedBy: divideInfo, imagesIn: url, saveTo: resizedDirURL)
        
        //        let isURLForImage = acceptedImagePathExtensions.contains(url.pathExtension)
        //        let isURLForDirectory = url.pathExtension.isEmpty
        //
        //        var imageURLs = [URL]()
        //
        //        if isURLForImage {
        //            imageURLs = [url]
        //        }
        //        else if isURLForDirectory {
        //            imageURLs =
        //            try FileManager.default.contentsOfDirectory(
        //                at: url, includingPropertiesForKeys: nil,
        //                options: [.skipsHiddenFiles])
        //                .filter{acceptedImagePathExtensions.contains($0.pathExtension)}
        //
        //        }else {
        //            throw(ResizeError.unvalidURL)
        //        }
        //
        
        
        
        
        //        //Start resizing and save
        //        for imageURL in imageURLs {
        //            let data = try Data(contentsOf: imageURL)
        //            let cfData = NSData(data: data) as CFData
        //            guard let source = CGImageSourceCreateWithData(cfData, nil) else {
        //                errors.append(.unvalidImageData)
        //                continue
        //            }
        //
        //            let size = configureImageSize(atSource: source)
        //            let divTwoSize = CGSize(width: size.width / 2, height: size.height / 2)
        //            let divThreeSize = CGSize(width: size.width / 3, height: size.height / 3)
        //
        //            print("@2: ", divTwoSize)
        //            print("@1:", divTwoSize)
        //
        //            guard let divTwoImage = drawCGImageUsingCoreGraphic(fromSource: source, toSize: divTwoSize),
        //                  let divThirdImage = drawCGImageUsingCoreGraphic(fromSource: source, toSize: divThreeSize) else {
        //                      errors.append(.bufferingError)
        //                      continue
        //                  }
        //
        //            //Save Images
        //            func saveImage(image: CGImage, withName name: String, to destination: URL) {
        //                let imageDestinationURL = destination.appendingPathComponent(name).appendingPathExtension("png") as CFURL
        //                let imageDestination = CGImageDestinationCreateWithURL(imageDestinationURL, ImageFormat.png.cfsting, 1, nil)!
        //                CGImageDestinationAddImage(imageDestination, image, nil)
        //                CGImageDestinationFinalize(imageDestination)
        //            }
        //
        //
        //            let baseName = url.deletingPathExtension().lastPathComponent
        //            let div3Name = baseName + "@1"
        //            let div2Name = baseName + "@2"
        //            let div1Name = baseName + "@3"
        //
        //            saveImage(image: divTwoImage, withName: div2Name, to: resizedDirURL)
        //            saveImage(image: divThirdImage, withName: div3Name, to: resizedDirURL)
        //            let dest333 = resizedDirURL.appendingPathComponent(div1Name).appendingPathExtension("png")
        //            try FileManager.default.copyItem(
        //                atPath: imageURL.path,
        //                toPath: resizedDirURL.appendingPathComponent(div1Name).appendingPathExtension("png").path)
        //
        //        }
        //
        //        errors.isEmpty ?
        //        print(" ✔ All files resized successfully") :
        //        print(" ✘ errors: \(errors)")
        
    }
    
    fileprivate func resize(dividedBy devides: [DivideImagInfo], imagesIn imagesURL: URL, saveTo saveDir: URL) throws {
        
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
            throw(ResizeError.unvalidURL)
        }
        
        var errors = [ResizeError]()
        
        for imageURL in imageURLs {
            let data = try Data(contentsOf: imageURL)
            let cfData = NSData(data: data) as CFData
            guard let source = CGImageSourceCreateWithData(cfData, nil) else {
                errors.append(.unvalidImageData)
                continue
            }
            
            let size = configureImageSize(atSource: source)
            
            for div in devides {
                let divSize = CGSize(width: size.width / div.divideBy, height: size.height / div.divideBy)
                guard let dividedImage = drawCGImageUsingCoreGraphic(fromSource: source, toSize: divSize) else {
                    errors.append(.bufferingError)
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

fileprivate struct DivideImagInfo {
    let divideBy: CGFloat
    let name: String
}

fileprivate enum IconTemplate: String {
    case android = "android"
    case ios = "ios"
}

struct InvalidTemplate: Error {}
