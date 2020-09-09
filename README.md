<img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=flat"> <img src="https://img.shields.io/badge/language-swift5.1-f48041.svg?style=flat">

# Resimage
A command-line tool written in swift that lets you resize your images super fast!

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

## TODO
* Resizing multiple images in a directory
* Resizing to iOS and Android standard icon sizes
