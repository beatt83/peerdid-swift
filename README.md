# PeerDID-swift

## Introduction

Welcome to `peerdid-swift`, a Swift package enabling the creation and resolution of Peer DIDs.

## Requirements

- Swift 5.8 or later
- Dependencies:
    - [swift-multibase](https://github.com/swift-libp2p/swift-multibase)
    - [swift-bases](https://github.com/swift-libp2p/swift-bases)
    
## Setup

1. Add peerdid-swift as a dependency in your Package.swift

```swift
.dependencies([
    .package(url: "git@github.com:beatt83/peerdid-swift.git", from: "0.0.5")
])
```

2. Add the PeerDID target to your target's dependencies

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
