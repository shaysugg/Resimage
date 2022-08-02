//
//  File.swift
//  
//
//  Created by Sha Yan on 1/2/21.
//

import Foundation
import ArgumentParser
import ImageIO

struct IOSIconCommand: ParsableCommand {
    
    public static let configurations = CommandConfiguration(abstract: "Resize 3X image(s) to 2X and 1X")
    
    @Argument(help: "Directory of pictures or path of a picture that you want to export them'\'it to iOS image sizes.")
    private var fromURL: String
    
    
    func run() throws {
        let acceptedImagePathExtensions = [ImageFormat.jpg.pathString, ImageFormat.png.pathString, ImageFormat.jpeg.pathString]
        
        var errors = [ResizeError]()
        
        //check url is image or diractory
        let url = URL(fileURLWithPath: fromURL)
        
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
        
        
        //Create a dir for the images that about to resize
        let resizedDirURL = url.deletingPathExtension().deletingLastPathComponent().appendingPathComponent("Resized-iOS")
        try FileManager.default.createDirectory(at: resizedDirURL, withIntermediateDirectories: true, attributes: nil)
        
        
        //Start resizing and save
        for imageURL in imageURLs {
            let data = try Data(contentsOf: imageURL)
            let cfData = NSData(data: data) as CFData
            guard let source = CGImageSourceCreateWithData(cfData, nil) else {
                errors.append(.unvalidImageData)
                continue
            }
            
            let size = configureImageSize(atSource: source)
            let divTwoSize = CGSize(width: size.width / 2, height: size.height / 2)
            let divThreeSize = CGSize(width: size.width / 3, height: size.height / 3)
            
            print("@2: ", divTwoSize)
            print("@1:", divTwoSize)
            
            guard let divTwoImage = drawCGImageUsingCoreGraphic(fromSource: source, toSize: divTwoSize),
                  let divThirdImage = drawCGImageUsingCoreGraphic(fromSource: source, toSize: divThreeSize) else {
                      errors.append(.bufferingError)
                      continue
                  }
            
            //Save Images
            func saveImage(image: CGImage, withName name: String, to destination: URL) {
                let imageDestinationURL = destination.appendingPathComponent(name).appendingPathExtension("png") as CFURL
                let imageDestination = CGImageDestinationCreateWithURL(imageDestinationURL, ImageFormat.png.cfsting, 1, nil)!
                CGImageDestinationAddImage(imageDestination, image, nil)
                CGImageDestinationFinalize(imageDestination)
            }
            
            
            
            let baseName = url.deletingPathExtension().lastPathComponent
            let div3Name = baseName + "@1"
            let div2Name = baseName + "@2"
            let div1Name = baseName + "@3"
            
            saveImage(image: divTwoImage, withName: div2Name, to: resizedDirURL)
            saveImage(image: divThirdImage, withName: div3Name, to: resizedDirURL)
            try FileManager.default.copyItem(
                at: imageURL,
                to: resizedDirURL.appendingPathComponent(div1Name).appendingPathExtension("png"))
            
        }
        
        errors.isEmpty ?
        print(" ✔ All files resized successfully") :
        print(" ✘ errors: \(errors)")
        
    }
    //name , dive by what size, parh =>
    
}
