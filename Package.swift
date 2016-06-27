import PackageDescription

let package = Package(
    name: "TodoListCouchDB",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/todolist-api.git", majorVersion: 0, minor: 2),
                      .Package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git", majorVersion: 0, minor: 16)
    ]
)
