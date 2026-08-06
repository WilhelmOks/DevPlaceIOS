import Foundation

public enum ChatSocketFrameDecoder {
    public static func decode(_ data: Data) -> ChatSocketEvent? {
        guard let typeHolder = try? decoder.decode(FrameType.self, from: data) else {
            return nil
        }
        switch typeHolder.type {
        case "ready":
            guard let frame = try? decoder.decode(ReadyFrame.self, from: data) else { return nil }
            return .ready(userUid: frame.user_uid)
        case "message":
            guard let frame = try? decoder.decode(MessageFrame.self, from: data) else { return nil }
            return .message(frame.incoming)
        case "typing":
            guard let frame = try? decoder.decode(TypingFrame.self, from: data) else { return nil }
            return .typing(fromUid: frame.from_uid)
        case "read":
            guard let frame = try? decoder.decode(ReadFrame.self, from: data) else { return nil }
            return .read(byUid: frame.by_uid)
        case "error":
            guard let frame = try? decoder.decode(ErrorFrame.self, from: data) else { return nil }
            return .failed(clientId: frame.client_id, text: frame.text)
        default:
            return nil
        }
    }

    private static let decoder = JSONDecoder.devPlace
}

public enum ChatSocketFrameEncoder {
    public static func send(receiverUid: String, content: String, attachmentUids: [String], clientId: String) -> String {
        encode(
            OutgoingSendFrame(
                receiver_uid: receiverUid,
                content: content,
                attachment_uids: attachmentUids,
                client_id: clientId,
            )
        )
    }

    public static func typing(receiverUid: String) -> String {
        encode(OutgoingTypingFrame(receiver_uid: receiverUid))
    }

    public static func read(withUid uid: String) -> String {
        encode(OutgoingReadFrame(with_uid: uid))
    }

    private static func encode(_ frame: some Encodable) -> String {
        guard let data = try? JSONEncoder().encode(frame) else { return "{}" }
        return String(decoding: data, as: UTF8.self)
    }
}

private struct FrameType: Decodable {
    let type: String
}

private struct ReadyFrame: Decodable {
    let user_uid: String
}

private struct TypingFrame: Decodable {
    let from_uid: String
}

private struct ReadFrame: Decodable {
    let by_uid: String
}

private struct ErrorFrame: Decodable {
    let client_id: String?
    let text: String
}

private struct MessageFrame: Decodable {
    let uid: String
    let sender_uid: String
    let receiver_uid: String
    let content: String
    let created_at: Date
    let attachments: [AttachmentFrame]?
    let client_id: String?

    var incoming: ChatSocketIncomingMessage {
        .init(
            uid: uid,
            senderUid: sender_uid,
            receiverUid: receiver_uid,
            content: content,
            createdAt: created_at,
            attachments: (attachments ?? []).map(\.attachment),
            clientId: client_id,
        )
    }
}

private struct AttachmentFrame: Decodable {
    let uid: String
    let filename: String?
    let url: String
    let size: Int?
    let is_image: Bool?
    let is_video: Bool?
    let mime_type: String?
    let created_at: Date?
    let can_modify: Bool?

    var attachment: Attachment {
        .init(
            id: uid,
            filename: filename,
            url: url,
            size: size,
            isImage: is_image ?? false,
            isVideo: is_video ?? false,
            mimeType: mime_type ?? "",
            createdAt: created_at ?? Date(),
            canModify: can_modify ?? false,
        )
    }
}

private struct OutgoingSendFrame: Encodable {
    let type = "send"
    let receiver_uid: String
    let content: String
    let attachment_uids: [String]
    let client_id: String
}

private struct OutgoingTypingFrame: Encodable {
    let type = "typing"
    let receiver_uid: String
}

private struct OutgoingReadFrame: Encodable {
    let type = "read"
    let with_uid: String
}
