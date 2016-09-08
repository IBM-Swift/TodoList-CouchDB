import PackageDescription

let package = Package(
    name: "TodoList",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/todolist-web",          majorVersion: 0, minor: 6),
        .Package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git",    majorVersion: 0, minor: 28),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git",      majorVersion: 0, minor: 15),
        .Package(url: "https://github.com/IBM-Swift/Swift-cfenv.git",       majorVersion: 1, minor: 6)
    ]
)
