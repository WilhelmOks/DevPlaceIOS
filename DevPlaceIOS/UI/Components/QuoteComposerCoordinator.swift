import SwiftUI

struct QuoteComposer {
    var isActive: Bool = false
    var insert: (String) -> Void = { _ in }
}

private struct QuoteComposerKey: EnvironmentKey {
    static let defaultValue = QuoteComposer()
}

extension EnvironmentValues {
    var quoteComposer: QuoteComposer {
        get { self[QuoteComposerKey.self] }
        set { self[QuoteComposerKey.self] = newValue }
    }
}
