import SharingGRDB
import SwiftUI

struct ContentView: View {
  @State private var hasTapped: Bool = false
  @State private var showingStep2: Bool = false

  var body: some View {
    NavigationStack {
      VStack(spacing: 20) {
        if !hasTapped {
          Button("Step 1: Click me") {
            hasTapped = true
            showingStep2 = true
          }
        }

        BugView()
      }
      .navigationDestination(isPresented: $showingStep2) {
        Step2View()
      }
    }
  }
}

struct BugView: View {
  @State private var vanillaSwiftUIState = "If you see this, vanilla SwiftUI has the bug too."
  @Fetch var data = Query.Value()

  var body: some View {
    VStack(spacing: 20) {
      VStack(spacing: .zero) {
        Text("SharingGRDB")
        Text(data.title)
      }

      VStack(spacing: .zero) {
        Text("Vanilla SwiftUI State")
        Text(vanillaSwiftUIState)
      }
    }

    .task {
      print("Setting values because the view appeared again.")

      vanillaSwiftUIState = "Vanilla SwiftUI is working"

      // NOTE: This is where the bug is happening. "Loading query" prints and we do get data back. However view ONLY updates with the empty initial value of the query and doesn't update again with the query result.

      try! await $data.load(Query())
    }
  }
}

struct Query: FetchKeyRequest {
  struct Value: Equatable, Sendable {
    var title: String = "If you see this, this is the initial value, not the query result we expected."
  }

  func fetch(_ db: Database) throws -> Value {
    try Value(
      title: Example.select(\.title).fetchOne(db) ?? "No value"
    )
  }
}

struct Step2View: View {
  var body: some View {
    Text("Now click the back button ↑")
  }
}
