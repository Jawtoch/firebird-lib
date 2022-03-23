// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "firebird-lib",
	platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "Firebird",
            targets: ["Firebird"]),
        .library(
            name: "FirebirdSQL",
            targets: ["FirebirdSQL"]),
    ],
    dependencies: [
		.package(url: "https://github.com/Jawtoch/Clibfbclient.git", from: "0.1.0"),
		.package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Firebird",
            dependencies: [
				.product(name: "Logging", package: "swift-log"),
				.product(name: "Clibfbclient", package: "Clibfbclient")
			]),
        .target(
            name: "FirebirdSQL",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Clibfbclient", package: "Clibfbclient")
            ]),
		.testTarget(
			name: "FirebirdTests",
			dependencies: ["Firebird"]),
        .testTarget(
            name: "FirebirdSQLTests",
            dependencies: ["FirebirdSQL"]),
    ]
)
