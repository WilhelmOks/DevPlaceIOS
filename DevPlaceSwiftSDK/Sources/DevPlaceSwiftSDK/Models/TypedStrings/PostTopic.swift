public enum PostTopic: String, CaseIterable, Hashable, Sendable {
    case random = "random"
    case devlog = "devlog"
    case showcase = "showcase"
    case question = "question"
    case rant = "rant"
    case fun = "fun"
    case politics = "politics"
    
    public var name: String {
        rawValue.capitalized
    }
}
