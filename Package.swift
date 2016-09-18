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
        .Package(url: "https://github.com/IBM-Swift/todolist-web",          majorVersion: 0, minor: 7),
        .Package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git",    majorVersion: 0, minor: 32),
        .Package(url: "https://github.com/IBM-Swift/Swift-cfenv.git",       majorVersion: 1, minor: 7)
    ]
)
