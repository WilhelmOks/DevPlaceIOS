public enum Vote: Hashable, Sendable {
    case up
    case down
    case none

    public init(value: Int) {
        self = switch value {
        case 1: .up
        case -1: .down
        default: .none
        }
    }

    public var value: Int {
        switch self {
        case .up: 1
        case .down: -1
        case .none: 0
        }
    }
}
