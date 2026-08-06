import Foundation
import DevPlaceSwiftSDK

final class LiveMessagesSocket: MessagesSocket {
    let events: AsyncStream<ChatSocketEvent>

    private let continuation: AsyncStream<ChatSocketEvent>.Continuation
    private let receiverUid: String
    private let urlProvider: () async throws -> URL
    private let urlSession: URLSession

    private var task: URLSessionWebSocketTask?
    private var connectionLoop: Task<Void, Never>?
    private var isActive = false

    init(receiverUid: String, urlProvider: @escaping () async throws -> URL) {
        self.receiverUid = receiverUid
        self.urlProvider = urlProvider
        self.urlSession = URLSession(configuration: .default)
        (events, continuation) = AsyncStream.makeStream()
    }

    func connect() {
        guard !isActive else { return }
        isActive = true
        connectionLoop = Task { [weak self] in
            await self?.runConnectionLoop()
        }
    }

    func disconnect() {
        isActive = false
        connectionLoop?.cancel()
        connectionLoop = nil
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
    }

    func send(content: String, attachmentUids: [String], clientId: String) async {
        await sendText(
            ChatSocketFrameEncoder.send(
                receiverUid: receiverUid,
                content: content,
                attachmentUids: attachmentUids,
                clientId: clientId,
            )
        )
    }

    func sendTyping() async {
        await sendText(ChatSocketFrameEncoder.typing(receiverUid: receiverUid))
    }

    func sendRead(withUid uid: String) async {
        await sendText(ChatSocketFrameEncoder.read(withUid: uid))
    }

    private func runConnectionLoop() async {
        var backoffMs: UInt64 = 200
        while isActive && !Task.isCancelled {
            do {
                let url = try await urlProvider()
                let socketTask = urlSession.webSocketTask(with: url)
                task = socketTask
                socketTask.resume()
                backoffMs = 200
                try await receiveLoop(socketTask)
            } catch {
                dlog("Chat socket connection error: \(error)")
            }

            continuation.yield(.disconnected)

            guard isActive && !Task.isCancelled else { break }

            let closeCode = task?.closeCode.rawValue ?? 0
            let delayMs: UInt64
            if closeCode == 4013 {
                delayMs = 200
            } else {
                delayMs = backoffMs
                backoffMs = min(backoffMs * 2, 5000)
            }
            dlog("Chat socket reconnecting in \(delayMs)ms (closeCode: \(closeCode))")
            try? await Task.sleep(for: .milliseconds(delayMs))
        }
    }

    private func receiveLoop(_ socketTask: URLSessionWebSocketTask) async throws {
        while isActive && !Task.isCancelled {
            let message = try await socketTask.receive()
            switch message {
            case .string(let text):
                if let data = text.data(using: .utf8) {
                    handle(data: data)
                }
            case .data(let data):
                handle(data: data)
            @unknown default:
                break
            }
        }
    }

    private func handle(data: Data) {
        guard let event = ChatSocketFrameDecoder.decode(data) else {
            dlog("Chat socket received unrecognized frame")
            return
        }
        continuation.yield(event)
    }

    private func sendText(_ text: String) async {
        guard let task else { return }
        do {
            try await task.send(.string(text))
        } catch {
            dlog("Chat socket send failed: \(error)")
        }
    }
}
