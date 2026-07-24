import Foundation
import DevPlaceSwiftSDK

extension Collection where Element == Post {
    static var mock: [Element] {
        [
            .init(
                data: .init(
                    id: "1",
                    title: "title 1",
                    topic: "topic 1",
                    content: "content 1",
                    slug: "mock-post-1",
                    userId: "u1",
                    stars: 3,
                    image: nil,
                    createdAt: Date().addingTimeInterval(-30),
                    updatedAt: Date().addingTimeInterval(-15),
                ),
                author: .mock,
                myVote: .none,
                commentCount: 2,
                recentComments: .mock,
                bookmarked: false,
                attachments: [
                    .init(
                        id: "att-1-1",
                        filename: "photo.jpg",
                        url: "https://picsum.photos/id/1015/600/400",
                        size: nil,
                        isImage: true,
                        isVideo: false,
                        mimeType: "image/jpeg",
                        createdAt: Date().addingTimeInterval(-30),
                        canModify: false,
                    ),
                ],
                poll: nil,
            ),
            .init(
                data: .init(
                    id: "2",
                    title: "title 2",
                    topic: "topic 2",
                    content: "content 2",
                    slug: "mock-post-2",
                    userId: "u1",
                    stars: 0,
                    image: nil,
                    createdAt: Date().addingTimeInterval(-30),
                    updatedAt: nil,
                ),
                author: .mock,
                myVote: .none,
                commentCount: 0,
                recentComments: [],
                bookmarked: false,
                attachments: [],
                poll: .mockLayoutContainer,
            ),
            .init(
                data: .init(
                    id: "3",
                    title: nil,
                    topic: "topic 3",
                    content: "content 3",
                    slug: "mock-post-3",
                    userId: "u1",
                    stars: 1,
                    image: nil,
                    createdAt: Date().addingTimeInterval(-60),
                    updatedAt: nil,
                ),
                author: .mock2,
                myVote: .up,
                commentCount: 0,
                recentComments: [],
                bookmarked: true,
                attachments: [
                    .init(
                        id: "att-3-1",
                        filename: "clip.mp4",
                        url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                        size: nil,
                        isImage: false,
                        isVideo: true,
                        mimeType: "video/mp4",
                        createdAt: Date().addingTimeInterval(-60),
                        canModify: false,
                    ),
                ],
                poll: .mockTestingFrameworkAlreadyVoted,
            ),
            .init(
                data: .init(
                    id: "4",
                    title: "title 4",
                    topic: nil,
                    content: "content 4",
                    slug: "mock-post-4",
                    userId: "u1",
                    stars: 42,
                    image: nil,
                    createdAt: Date().addingTimeInterval(-60 * 60),
                    updatedAt: nil,
                ),
                author: .mock,
                myVote: .none,
                commentCount: 0,
                recentComments: [],
                bookmarked: false,
                attachments: [],
                poll: .mockConcurrency,
            ),
            .init(
                data: .init(
                    id: "5",
                    title: nil,
                    topic: nil,
                    content: """
                        content 5
                        Here is some *italic* text and here is some **bold** text.
                        > blockquote
                        asdf

                        lorem ipsum

                        ```
                        code block
                        line 2
                        ```

                        Text with `inline code` in it.

                        end
                        """,
                    slug: "mock-post-5",
                    userId: "u1",
                    stars: 1337,
                    image: nil,
                    createdAt: Date().addingTimeInterval(-60 * 60 * 24),
                    updatedAt: nil,
                ),
                author: .mock2,
                myVote: .down,
                commentCount: 0,
                recentComments: [],
                bookmarked: false,
                attachments: [
                    .init(
                        id: "att-5-1",
                        filename: "landscape.jpg",
                        url: "https://picsum.photos/id/1018/800/500",
                        size: nil,
                        isImage: true,
                        isVideo: false,
                        mimeType: "image/jpeg",
                        createdAt: Date().addingTimeInterval(-60 * 60 * 24),
                        canModify: false,
                    ),
                ],
                poll: nil,
            ),
        ]
    }
}
