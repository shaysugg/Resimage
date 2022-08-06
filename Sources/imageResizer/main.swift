import ArgumentParser
import Foundation


struct Resimage: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Resimage is a Swift Command-line tool for resizing images.",
        subcommands: [Resize.self, CompressMultiple.self, IconResizeCommand.self] )

    init() {}
}


Resimage.main()








