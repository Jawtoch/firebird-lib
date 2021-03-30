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
		.package(url: "https://github.com/Jawtoch/CFirebird.git", from: "0.1.0"),
		.package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Firebird",
            dependencies: [
				.product(name: "Logging", package: "swift-log"),
				.product(name: "CFirebird", package: "CFirebird"),
			]),
		.testTarget(
			name: "FirebirdTests",
			dependencies: ["Firebird"]),
    ]
)
