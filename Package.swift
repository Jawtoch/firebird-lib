// swift-tools-version:5.0.0

import PackageDescription

let package = Package(
    name: "firebird-lib",
	platforms: [
		.macOS(.v10_10),
	],
    products: [
        .library(
			name: "Firebird",
			targets: ["Firebird"]),
	],
    dependencies: [
		.package(
			url: "https://github.com/ugocottin/CFirebird.git",
			from: "0.1.0"),
		.package(
			url: "https://github.com/apple/swift-log.git",
			from: "1.4.0"),
		.package(
			url: "https://github.com/apple/swift-nio.git",
			from: "2.40.0"),
    ],
    targets: [
        .target(
			name: "Firebird",
			dependencies: [
				.product(
					name: "CFirebird",
					package: "CFirebird"),
				.product(
					name: "Logging",
					package: "swift-log"),
				.product(
					name: "NIOCore",
					package: "swift-nio"),
			]),
		.testTarget(
			name: "FirebirdTests",
			dependencies: [
				.target(name: "Firebird"),
				.product(
					name: "NIO",
					package: "swift-nio"),
			]),
    ]
)
