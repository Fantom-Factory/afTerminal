#ANSI Terminal v0.9.0
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom-lang.org/)
[![pod: v0.9.0](http://img.shields.io/badge/pod-v0.9.0-yellow.svg)](http://www.fantomfactory.org/pods/afTerminal)
![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)

## Overview

An FWT widget that prints ANSI escape sequences.

Features:

- 256 Colour VGA palette or full colour
- Foreground and background colours, palette index and full colour
- Bold, italic, underline, and crossed out fonts
- Cursor commands for up, down, left, right, absolute, save, restore
- Clear commands for line and screen

`AnsiTerminal` wraps a `RichText` widget and provides methods to print ANSI escape sequences.

The `AnsiBuf` class provides convenient methods for generating ANSI escape sequences.

## Install

Install `ANSI Terminal` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afTerminal

Or install `ANSI Terminal` with [fanr](http://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afTerminal

To use in a [Fantom](http://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afTerminal 0.9"]

## Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afTerminal/) - the Fantom Pod Repository.

## Quick Start

1. Create a text file called `Example.fan`

        using gfx::Size
        using fwt::Window
        using afTerminal
        
        class Example {
            Void main() {
                term := AnsiTerminal()
                ansi := AnsiBuf()
                    .fgIdx( 9).print("RED\n").reset
                    .fgIdx(10).print("GREEN\n").reset
                    .fgIdx(12).print("BLUE\n").reset
                    .underline.print("Underline").reset
        
                Window {
                    it.title = "ANSI Terminal"
                    it.size = Size(320, 200)
                    it.add(term.richText)
                    it.onOpen.add |->| {
                        term.print(ansi)
                    }
                }.open
            }
        }


2. Run `Example.fan` as a Fantom script from the command line:

        C:\> fan Example.fan



  ![ANSI Terminal Example](data:image/png;base64,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)



