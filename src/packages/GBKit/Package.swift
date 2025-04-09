// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "GBKit",
    platforms: [.iOS(.v15),.macCatalyst(.v14), .macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GBKit",
            targets: ["GBKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GBKit",
            dependencies: []),
        .testTarget(
            name: "GBKitTests",
            dependencies: ["GBKit"]),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
