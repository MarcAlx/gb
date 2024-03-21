# Game Boy Emulator

A Game Boy Emulator for iOS / macOS written in Swift.

## Compatibility

This projects aims at being compatible with the following platforms:

- iOS (14+)
- iPadOS (14+)
- macCatalyst (14+)
- SwiftPlayground (both macOS and iPadOS (WIP @see roadmap))

_n.b not compatible with .macOS(.v14) as `CADisplayLink.init(target:selector:)` is not available on macOS. @see https://developer.apple.com/documentation/quartzcore/cadisplaylink/1621228-init_

## Getting started

Open either `./src/app/GameBoyEmulator/GameBoyEmulator.xcodeproj` or `./src/app/GameBoyEmulator.swiftpm` with `xcode` on macOS.

_n.b Swift PlayGround is also supported on macOS but debugging remains impossible as long as performance which are tied to debug xcscheme._ 

## Structure

This project is a mono repo that holds the following:

- The emulator app in `./src/app`
- An UI package `GBUIKit` in `./packages/GBUIKit`
- A core package package `GBKit` in `./packages/GBKit`

## Roadmap

1. Explode GBKit and GBUIKit to their own repo in order to ensure compatibility with SwiftPlayground (iPadOS) that doesnt supports local packages.

## side notes

Game Boy and Nintendo are used under [nominative use](https://en.wikipedia.org/wiki/Nominative_use). As for logo's bytes inclusion please read [Sega v. Accolade](https://en.wikipedia.org/wiki/Sega_v._Accolade).