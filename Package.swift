import PackageDescription

let package = Package(
    name: "TodoList",
    targets: [
        Target(
            name: "Server",
            dependencies: [.Target(name: "TodoList")]
        ),
        Target(
            name: "TodoList"
        )
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git",                majorVersion: 1),
        .Package(url: "https://github.com/davidungar/miniPromiseKit",           majorVersion: 4),
        .Package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git",        majorVersion: 1),
        .Package(url: "https://github.com/IBM-Swift/CloudConfiguration.git",    majorVersion: 1),
        .Package(url: "https://github.com/IBM-Bluemix/cf-deployment-tracker-client-swift.git", majorVersion: 2)
    ]
)
