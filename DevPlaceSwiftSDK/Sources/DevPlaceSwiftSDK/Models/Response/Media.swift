import Foundation

public struct Media: Hashable, Sendable, Identifiable {
    public let id: String
    public let originalFilename: String
    public let fileSize: Int
    public let mimeType: String
    public let url: String
    public let thumbnailUrl: String
    public let hasThumbnail: Bool
    public let isImage: Bool
    public let isVideo: Bool
    public let targetType: String
    public let targetId: String
    public let targetUrl: String
    public let createdAt: Date

    public init(
        id: String,
        originalFilename: String,
        fileSize: Int,
        mimeType: String,
        url: String,
        thumbnailUrl: String,
        hasThumbnail: Bool,
        isImage: Bool,
        isVideo: Bool,
        targetType: String,
        targetId: String,
        targetUrl: String,
        createdAt: Date,
    ) {
        self.id = id
        self.originalFilename = originalFilename
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.url = url
        self.thumbnailUrl = thumbnailUrl
        self.hasThumbnail = hasThumbnail
        self.isImage = isImage
        self.isVideo = isVideo
        self.targetType = targetType
        self.targetId = targetId
        self.targetUrl = targetUrl
        self.createdAt = createdAt
    }
}

extension Media {
    struct CodingData: Decodable {
        let uid: String
        let original_filename: String
        let file_size: Int
        let mime_type: String
        let url: String
        let thumbnail_url: String
        let has_thumbnail: Bool
        let is_image: Bool
        let is_video: Bool
        let target_type: String
        let target_uid: String
        let target_url: String
        let created_at: Date
    }
}

extension Media.CodingData {
    var decoded: Media {
        .init(
            id: uid,
            originalFilename: original_filename,
            fileSize: file_size,
            mimeType: mime_type,
            url: url,
            thumbnailUrl: thumbnail_url,
            hasThumbnail: has_thumbnail,
            isImage: is_image,
            isVideo: is_video,
            targetType: target_type,
            targetId: target_uid,
            targetUrl: target_url,
            createdAt: created_at,
        )
    }
}
