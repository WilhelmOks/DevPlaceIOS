import Foundation

final class MockMessagesSocket: MessagesSocket {
    let events: AsyncStream<ChatSocketEvent>

    private let continuation: AsyncStream<ChatSocketEvent>.Continuation

    init() {
        (events, continuation) = AsyncStream.makeStream()
    }

    func connect() async {}

    func disconnect() async {
        continuation.finish()
    }

    func send(content: String, attachmentUids: [String], clientId: String) async {}

    func sendTyping() async {}

    func sendRead(withUid uid: String) async {}
}
