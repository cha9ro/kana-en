// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "KanaEn",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "KanaEn", targets: ["KanaEn"])
    ],
    targets: [
        .executableTarget(
            name: "KanaEn",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("Carbon"),
                .linkedFramework("ServiceManagement")
            ]
        ),
        .testTarget(name: "KanaEnTests", dependencies: ["KanaEn"])
    ]
)
