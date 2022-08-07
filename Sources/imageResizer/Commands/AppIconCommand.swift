//
//  File.swift
//  
//
//  Created by Sha Yan on 5/16/1401 AP.
//

import Foundation
import ArgumentParser
import ImageIO

struct AppIconCommand: ParsableCommand {
    
    //TODO: Better abstract
    public static let configurations = CommandConfiguration(
        commandName: "app-icon",
        abstract: """
    Create different app icon size based on the given image path. For full functionality the image size should be bigger than 1024x1024 for iOS and ... for Android
    """)
    
    @Argument(help: "Path of the image that you want to export it as app icon.")
    private var fromURL: String
    
    @Option(name: .shortAndLong, help: "App Icon template, can be android or ios.")
    private var template: String
    
    func run() throws {
        guard let appIconTemplate = AppIconTemplate(rawValue: template) else {
            throw InvalidAppIconTemplate()
        }
        
        let url = URL(fileURLWithPath: fromURL)
        let imageName = url.deletingPathExtension().lastPathComponent
        
        func imageNamewith(_ string: String) -> String {
            imageName + string
        }
        
        //Configure app icon sizes for each template
        var sizes: [AppIconSize] {
            switch appIconTemplate {
            case .android:
                return [
                ]
            case .ios:
                return [
                    AppIconSize(size: CGSize(width: 20, height: 20), name: imageNamewith("20@1x")),
                    AppIconSize(size: CGSize(width: 30, height: 30), name: imageNamewith("20@2x")),
                    AppIconSize(size: CGSize(width: 60, height: 60), name: imageNamewith("20@3x")),
                    
                    AppIconSize(size: CGSize(width: 29, height: 29), name: imageNamewith("29@1x")),
                    AppIconSize(size: CGSize(width: 29 * 2, height: 29 * 2), name: imageNamewith("29@2x")),
                    AppIconSize(size: CGSize(width: 29 * 3, height: 29 * 3), name: imageNamewith("29@3x")),
                    
                    AppIconSize(size: CGSize(width: 40, height: 40), name: imageNamewith("40@1x")),
                    AppIconSize(size: CGSize(width: 80, height: 80), name: imageNamewith("40@2x")),
                    AppIconSize(size: CGSize(width: 120, height: 120), name: imageNamewith("40@3x")),
                    
                    AppIconSize(size: CGSize(width: 76, height: 76), name: imageNamewith("76@1x")),
                    AppIconSize(size: CGSize(width: 76 * 2, height: 76 * 2), name: imageNamewith("76@2x")),
                    
                    AppIconSize(size: CGSize(width: 83.5, height: 83.5), name: imageNamewith("76@2x")),
                    
                    AppIconSize(size: CGSize(width: 1024, height: 1024), name: imageNamewith("")),
                ]
            }
        }
        
        
        //Create a directory for saving app icons
        let resizedDirURL = url.deletingPathExtension().deletingLastPathComponent().appendingPathComponent("iOS-app-icon")
        try? FileManager.default.createDirectory(at: resizedDirURL, withIntermediateDirectories: true, attributes: nil)
        
        //Create CGImage source
        guard let data = try? Data(contentsOf: url) else {throw ResizeError.unvalidURL }
        let cfData = NSData(data: data) as CFData
        guard let imageSource = CGImageSourceCreateWithData(cfData, nil) else { throw ResizeError.unvalidImageData }
           
        var errors = [ResizeError]()
        
        //Resize Image to different app icon sizes and save them
        for sizeInfo in sizes {
            guard let image = drawCGImageUsingCoreGraphic(fromSource: imageSource, toSize: sizeInfo.size) else {
                print(" ✘ Resizing \(sizeInfo.name) failed!")
                errors.append(.resizingImage)
                continue
            }
            let destenationURL = resizedDirURL.appendingPathComponent(sizeInfo.name).appendingPathExtension(ImageFormat.png.pathString)
            guard let destenation = CGImageDestinationCreateWithURL(destenationURL as CFURL, ImageFormat.png.cfsting, 1, nil)
                else { throw ResizeError.unvalidStoreToPath }
            CGImageDestinationAddImage(destenation, image, nil)
            CGImageDestinationFinalize(destenation)
            
            print(" ✔ Resized \(sizeInfo.name)")
        }
    }
}

fileprivate enum AppIconTemplate: String {
    case android = "android"
    case ios = "ios"
}

struct AppIconSize {
    let size: CGSize
    let name: String
}

struct InvalidAppIconTemplate: Error {}
