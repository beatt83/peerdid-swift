// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "peerdid-swift",
    products: [
        .library(
            name: "PeerDID",
            targets: ["PeerDID"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-libp2p/swift-multibase.git", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/swift-libp2p/swift-bases.git", .upToNextMajor(from: "0.0.3")),
        .package(path: "../didcore-swift")
    ],
    targets: [
        .target(
            name: "PeerDID",
            dependencies: [
                .product(name: "Multibase", package: "swift-multibase"),
                .product(name:  "BaseX", package: "swift-bases"),
                .product(name:  "Base64", package: "swift-bases"),
                .product(name: "DIDCore", package: "didcore-swift")
            ]
        ),
        .testTarget(
            name: "PeerDIDTests",
            dependencies: [
                "PeerDID",
                .product(name: "DIDCore", package: "didcore-swift")
            ]),
    ]
)
