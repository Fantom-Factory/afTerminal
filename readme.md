#ANSI Terminal v0.0.0
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom-lang.org/)
[![pod: v0.0.0](http://img.shields.io/badge/pod-v0.0.0-yellow.svg)](http://www.fantomfactory.org/pods/afTerminal)
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

    depends = ["sys 1.0", ..., "afTerminal 0.0"]

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



  ![ANSI Terminal Example](http://eggbox.fantomfactory.org/pods/afTerminal/doc/ansiTerminal.png)



