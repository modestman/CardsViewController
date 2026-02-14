// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CardsViewController",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "CardsViewController",
            targets: ["CardsViewController"]
        )
    ],
    targets: [
        .target(
            name: "CardsViewController"
        )
    ]
)
