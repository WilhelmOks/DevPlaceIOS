public enum NotificationType: String, Hashable, Sendable {
    case comment = "comment"
    case reply = "reply"
    case mention = "mention"
    case vote = "vote"
    case message = "message"
    case issue = "issue"
}
