// TODO: Accessibility pass

import ComposableArchitecture
import SharingGRDB
import SwiftUI

@main
struct FetchBugReproductionApp: App {
  @Dependency(\.context) private var context

  init() {
    withErrorReporting {
      if context == .live {
        try prepareDependencies {
          $0.defaultDatabase = try appDatabase()
        }
      }
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
