import Foundation
import SharingGRDB

@Table
struct Example: Identifiable, Hashable, Sendable {
  let id: Int
  let title: String
}

public func appDatabase() throws -> any DatabaseWriter {
  @Dependency(\.context) var context

  // Prepare the configuration
  var configuration = Configuration()
  configuration.foreignKeysEnabled = true
  #if DEBUG
    configuration.prepareDatabase { db in
      db.trace(options: .profile) {
        print("\($0.expandedDescription)")
      }
    }
  #endif

  // Create the database in different ways, depending on the context.
  let database: any DatabaseWriter
  if context == .live {
    // Our main location
    let path = URL.documentsDirectory.appending(component: "db.sqlite").path()
    print("open \(path)")
    database = try DatabasePool(path: path, configuration: configuration)
  } else if context == .test {
    // A throw away location in tmp so it'll get cleaned up by the system
    let path = URL.temporaryDirectory.appending(component: "\(UUID().uuidString)-db.sqlite").path()
    database = try DatabasePool(path: path, configuration: configuration)
  } else {
    // Memory only for previews
    database = try DatabaseQueue(configuration: configuration)
  }

  // Handle migrations
  var migrator = DatabaseMigrator()
  #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
  #endif

  migrator.registerMigration("Migration") { db in
    try #sql(
      """
      CREATE TABLE "Examples" (
        "id" INT PRIMARY KEY NOT NULL,
        "title" STRING NOT NULL
      )
      """
    )
    .execute(db)
  }

  try migrator.migrate(database)

  // Seed the database if needed
  #if DEBUG
    switch context {
    case .preview:
      try database.write { db in
        try db.seed {
          Example(id: 0, title: "You are seeing this text because the query loaded correctly.")
        }
      }

    case .live:
      try database.write { db in
        guard try Example.all.fetchOne(db) == nil else { return }
        try db.seed {
          Example(id: 0, title: "This query is showing data")
        }
      }

    default: break
    }

  #endif

  return database
}
