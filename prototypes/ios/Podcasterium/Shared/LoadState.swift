import SwiftUI

enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(Error)

    var value: Value? {
        if case .loaded(let v) = self { return v }
        return nil
    }
}

/// Centered spinner or error with retry; wraps the loaded content.
struct LoadStateView<Value, Content: View>: View {
    let state: LoadState<Value>
    let retry: () -> Void
    @ViewBuilder let content: (Value) -> Content

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let error):
            ContentUnavailableView {
                Label("Could not load", systemImage: "wifi.exclamationmark")
            } description: {
                Text(error.localizedDescription)
            } actions: {
                Button("Retry", action: retry).buttonStyle(.borderedProminent)
            }
        case .loaded(let value):
            content(value)
        }
    }
}
