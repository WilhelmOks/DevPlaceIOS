public enum Vote: Hashable, Sendable {
    case up
    case down
    case none

    public var value: Int {
        switch self {
        case .up: 1
        case .down: -1
        case .none: 0
        }
    }
}
