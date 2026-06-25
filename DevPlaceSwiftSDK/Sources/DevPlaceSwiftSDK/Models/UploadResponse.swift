public struct UploadResponse: Hashable, Sendable, Identifiable {
    public let id: String
    public let filename: String
    public let url: String
    public let size: Int
    public let isImage: Bool
    public let isVideo: Bool
    public let mimeType: String

    public init(
        id: String,
        filename: String,
        url: String,
        size: Int,
        isImage: Bool,
        isVideo: Bool,
        mimeType: String,
    ) {
        self.id = id
        self.filename = filename
        self.url = url
        self.size = size
        self.isImage = isImage
        self.isVideo = isVideo
        self.mimeType = mimeType
    }
}

extension UploadResponse {
    struct CodingData: Decodable {
        let uid: String
        let filename: String
        let url: String
        let size: Int
        let is_image: Bool
        let is_video: Bool
        let mime_type: String
    }
}

extension UploadResponse.CodingData {
    var decoded: UploadResponse {
        .init(
            id: uid,
            filename: filename,
            url: url,
            size: size,
            isImage: is_image,
            isVideo: is_video,
            mimeType: mime_type,
        )
    }
}
