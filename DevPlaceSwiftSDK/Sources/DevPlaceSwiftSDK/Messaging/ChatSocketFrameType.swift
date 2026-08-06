enum ChatSocketServerFrameType: String, Hashable, Sendable {
    case ready = "ready"
    case message = "message"
    case typing = "typing"
    case read = "read"
    case error = "error"
}

enum ChatSocketClientFrameType: String, Hashable, Sendable {
    case send = "send"
    case typing = "typing"
    case read = "read"
}
