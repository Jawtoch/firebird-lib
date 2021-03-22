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
		.package(url: "https://github.com/Jawtoch/firebird-headers.git", from: "0.2.0"),
    ],
    targets: [
		.binaryTarget(name: "FirebirdFramework", path: "Firebird.xcframework"),
        .target(
            name: "Firebird",
            dependencies: [
				.byName(name: "FirebirdFramework"),
				.product(name: "FirebirdHeaders", package: "firebird-headers"),
			]),
		.testTarget(
			name: "FirebirdTests",
			dependencies: ["Firebird"]),
    ]
)
