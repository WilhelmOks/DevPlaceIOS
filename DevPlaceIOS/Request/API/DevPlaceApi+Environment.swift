import SwiftUI

private struct DevPlaceApiKey: EnvironmentKey {
    static let defaultValue: DevPlaceApi = .prod
}

extension EnvironmentValues {
    var api: DevPlaceApi {
        get { self[DevPlaceApiKey.self] }
        set { self[DevPlaceApiKey.self] = newValue }
    }
}
