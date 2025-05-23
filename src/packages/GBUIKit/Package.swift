// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "GBUIKit",
    platforms: [.iOS(.v16),.macCatalyst(.v16)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GBUIKit",
            targets: ["GBUIKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../GBKit")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GBUIKit",
            dependencies: [.product(name: "GBKit", package: "GBKit")]),
        .testTarget(
            name: "GBUIKitTests",
            dependencies: ["GBUIKit","GBKit"]),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
