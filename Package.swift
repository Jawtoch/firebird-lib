// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "firebird-lib",
    products: [
        .library(
            name: "Firebird",
            targets: ["Firebird"]),
    ],
    dependencies: [
		.package(url: "git@github.com:Jawtoch/firebird-headers.git", from: "0.3.1"),
		.package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
		.binaryTarget(name: "FirebirdFramework", path: "Firebird.xcframework"),
        .target(
            name: "Firebird",
            dependencies: [
				.byName(name: "FirebirdFramework"),
				.product(name: "FirebirdHeaders", package: "firebird-headers"),
				.product(name: "Logging", package: "swift-log"),
			]),
		.testTarget(
			name: "FirebirdTests",
			dependencies: ["Firebird"]),
    ]
)
