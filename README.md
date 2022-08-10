<img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=flat"> <img src="https://img.shields.io/badge/language-swift5.1-f48041.svg?style=flat">

# Resimage
A command-line tool written in swift for resizing images super fast!

## Usage
* **Resize an image**
```
$ resimage resize --help

OVERVIEW: Resimage is a Swift Command-line tool for resizing images.

USAGE: resimage <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  resize                  Resize image based on given width or heigh.
  compress                Compress images that exist in a diractory
  icon                    Resize the given image to each platform required icon
                          size
  app-icon                Create required platform app icons from the given
                          image path. For full functionality the image size
                          should be bigger than 1024x1024 for iOS
```

## Examples

```
//Change image width to 100 by keeping its ratio.
$ resimage resize ~/desktop/picture.jpg --width 100

//Change image width to 100 and height to 200 and format to png.
$ resimage resize ~/desktop/picture.jpg --width 100 --height 200 -f png

//Change image width to 100 by keeping its ratio and store it to the given path.
$ resimage resize ~/desktop/picture.jpg --width 100 -s ~/desktop/resized/resizedpicture.jpg

//Compress all images that exist in pictures directory to have half of the size of they had and store them to resized directory.
$ resimage compress-multiple ~/desktop/pictures -c 0.5 -s ~/desktop/resized/

//Resize the source images to iOS image required sizes. (1X, 2X, 3X)
$ resimage icon ~/desktop/pictures/picture.png --platform iOS

//Generate iOS required app icons based on the given path.
$ resimage app-icon ~/desktop/pictures/picture.png --platform iOS
```

## Installation 

* Using [Mint](https://github.com/yonaskolb/mint)
```
$ mint install shaysugg/Resimage
```
* Manually 
```
$ git clone https://github.com/shaysugg/Resimage.git
$ cd Resimage
$ swift build --configuration release
$ cp -f .build/release/resimage /usr/local/bin/resimage
```

## TODO
- [X] Compress multiple images of a directory
- [X] Resize to iOS and Android icon sizes
