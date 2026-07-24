import Foundation
import DevPlaceSwiftSDK

extension PostDetail {
    static var mock: PostDetail {
        .init(
            post: .init(
                id: "1",
                title: "A post with several attachments",
                topic: "swift",
                content: """
                    This is the full post detail content.
                    Here is some *italic* text and some **bold** text.

                    ```
                    let answer = 42
                    ```

                    end
                    """,
                slug: "a-post-with-several-attachments",
                userId: "u1",
                stars: 12,
                image: nil,
                createdAt: Date().addingTimeInterval(-60 * 60),
                updatedAt: nil,
            ),
            author: .mock,
            isOwner: false,
            starCount: 12,
            myVote: 1,
            comments: .mock,
            attachments: [
                .init(
                    id: "att-detail-1",
                    filename: "photo.jpg",
                    url: "https://picsum.photos/id/1015/600/400",
                    size: nil,
                    isImage: true,
                    isVideo: false,
                    mimeType: "image/jpeg",
                    createdAt: Date().addingTimeInterval(-60 * 60),
                    canModify: false,
                ),
                .init(
                    id: "att-detail-2",
                    filename: "landscape.jpg",
                    url: "https://picsum.photos/id/1018/800/500",
                    size: nil,
                    isImage: true,
                    isVideo: false,
                    mimeType: "image/jpeg",
                    createdAt: Date().addingTimeInterval(-60 * 60),
                    canModify: false,
                ),
                .init(
                    id: "att-detail-3",
                    filename: "clip.mp4",
                    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                    size: nil,
                    isImage: false,
                    isVideo: true,
                    mimeType: "video/mp4",
                    createdAt: Date().addingTimeInterval(-60 * 60),
                    canModify: false,
                ),
            ],
            bookmarked: false,
            poll: .mockConcurrency,
            commentCount: 2,
            relatedPosts: [],
            topics: ["swift", "ios"],
        )
    }
}
