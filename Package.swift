import PackageDescription

let package = Package(
    name: "TodoList",
    targets: [
        Target(
            name: "Deploy",
            dependencies: [.Target(name: "TodoList")]
        ),
        Target(
            name: "TodoList"
        )
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git",            majorVersion: 1, minor: 2),
        .Package(url: "https://github.com/davidungar/miniPromiseKit",       majorVersion: 4, minor: 1),
        .Package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git",    majorVersion: 1, minor: 2),
        .Package(url: "https://github.com/IBM-Swift/Swift-cfenv.git",       majorVersion: 1, minor: 8)
    ]
)
