<img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=flat"> <img src="https://img.shields.io/badge/language-swift5.1-f48041.svg?style=flat">

# Resimage
A command-line tool written in swift for resizing your images super fast!

## Usage
```
$ Resimage resize --help

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

### Examples

```
$ resimage resize ~/desktop/picture.jpg --width 100
$ resimage resize ~/desktop/picture.jpg --width 100 --height 200 -f png
$ resimage resize ~/desktop/picture.jpg --width 100 -s ~/desktop/resized/resizedpicture.jpg
```

### Installation 
- Using [Mint](https://github.com/yonaskolb/mint)
```
$ mint install shaysugg/Resimage
```
- Manually 
```
$ git clone https://github.com/shaysugg/Resimage.git
$ cd Resimage
$ swift build --configuration release
$ cp -f .build/release/resimage /usr/local/bin/resimage
```

## TODO
* Resizing multiple images in a directory
* Resizing to iOS and Android standard icon sizes
