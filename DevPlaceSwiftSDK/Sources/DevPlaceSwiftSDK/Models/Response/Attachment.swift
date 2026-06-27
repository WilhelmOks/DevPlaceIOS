import Foundation

public struct Attachment: Hashable, Sendable, Identifiable {
    public let id: String
    public let filename: String?
    public let url: String
    public let size: Int?
    public let isImage: Bool
    public let isVideo: Bool
    public let mimeType: String
    public let createdAt: Date
    public let canModify: Bool

    public init(
        id: String,
        filename: String?,
        url: String,
        size: Int?,
        isImage: Bool,
        isVideo: Bool,
        mimeType: String,
        createdAt: Date,
        canModify: Bool,
    ) {
        self.id = id
        self.filename = filename
        self.url = url
        self.size = size
        self.isImage = isImage
        self.isVideo = isVideo
        self.mimeType = mimeType
        self.createdAt = createdAt
        self.canModify = canModify
    }
}

extension Attachment {
    struct CodingData: Decodable {
        let uid: String
        let filename: String?
        let url: String
        let size: Int?
        let is_image: Bool
        let is_video: Bool
        let mime_type: String
        let created_at: Date
        let can_modify: Bool
    }
}

extension Attachment.CodingData {
    var decoded: Attachment {
        .init(
            id: uid,
            filename: filename,
            url: url,
            size: size,
            isImage: is_image,
            isVideo: is_video,
            mimeType: mime_type,
            createdAt: created_at,
            canModify: can_modify,
        )
    }
}
