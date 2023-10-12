# PeerDID-swift

## Introduction

Welcome to `peerdid-swift`, a Swift package enabling the creation and resolution of Peer DIDs.

[PeerDID Specification](https://identity.foundation/peer-did-method-spec/)

[![Swift](https://img.shields.io/badge/swift-brightgreen.svg)]() [![iOS](https://img.shields.io/badge/ios-brightgreen.svg)]() [![MacOS](https://img.shields.io/badge/macos-brightgreen.svg)]() [![WatchOS](https://img.shields.io/badge/watchos-brightgreen.svg)]() [![TvOS](https://img.shields.io/badge/tvos-brightgreen.svg)]()

## Requirements

- Swift 5.8 or later
- Dependencies:
    - [didcore-swift](https://github.com/beatt83/didcore-swift)
    - [swift-multibase](https://github.com/swift-libp2p/swift-multibase)
    - [swift-bases](https://github.com/swift-libp2p/swift-bases)

## Installation

### Swift Package Manager (SPM)

To integrate `DIDCore` into your Xcode project using SPM, specify it in your `Package.swift`:

```swift
dependencies: [
    .package(url: "git@github.com:beatt83/peerdid-swift.git", .upToNextMajor(from: "1.0.0"))
]
```

Add the PeerDID target to your target's dependencies:

```swift
.target(name: "YOUR_TARGET_NAME", dependencies: [
    .product(name: "PeerDID", package: "peerdid-swift"),
    // ... other dependencies
])
```
## Contribution

Feel free to contribute by opening issues, proposing pull requests, or suggesting better ways to create and resolve Peer DIDs in Swift. All contributions are welcome!

## License

This project is licensed under the Apache License 2.0. See the LICENSE file for details.
