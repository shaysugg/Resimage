<img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=flat"> <img src="https://img.shields.io/badge/language-swift5.1-f48041.svg?style=flat">

# Resimage
A command-line tool written in swift for resizing your images super fast!

## Usage
* **Resizie an image**
```
$ resimage resize --help

OVERVIEW: Resize image based on given width or heigh.

USAGE: resimage resize <from-url> [--store-to <store-to>] [--width <width>] [--height <height>] [--format <format>]

ARGUMENTS:
  <from-url>              URL of the image you want to resize.

OPTIONS:
  -s, --store-to <store-to>
                          URL of the place that you want to save the resized
                          image.
  --width <width>         Resize width, Don't pass it if you want this to be
                          calculate based on the height that you will pass.
  --height <height>       Resize height, Don't pass it if you want this to
                          be calculate based on the width that you will
                          pass.
  -f, --format <format>   Should pass png or jpg
  -h, --help              Show help information.
```
*  **Compress multiple images**
```
OVERVIEW: Compress images that exist in a diractory

USAGE: resimage compress-multiple <images-directory-path> [--compress <compress>] [--store-to <store-to>]

ARGUMENTS:
  <images-directory-path> The directory that contains images you want to compress

OPTIONS:
  -c, --compress <compress>
                          Amount of Compression you want, Should be between 0 to 1.
  -s, --store-to <store-to>
                          URL of the directory that you want to save compressed images.
  -h, --help              Show help information.
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
[X]- Compress multiple images of a directory
[ ]- Resize to iOS and Android standard icon sizes
