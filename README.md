# TCA Fetch Bug Reproduction

When loading a query from inside a task in a SwiftUI view, the query fails to update the view once the query resolves. It looks something like:

1. Initial view load. The query returns data and the view shows it.
2. Navigate away.
3. Navigate back.
4. The query runs again. It rests and the view shows the initial data. The query then returns data, but the view doesn't update. It still shows the initial data.
