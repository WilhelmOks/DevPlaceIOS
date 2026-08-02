import Foundation
import DevPlaceSwiftSDK

extension Collection where Element == Post {
    static var mock: [Element] {
        [
            .init(
                data: .init(
                    id: "1",
                    title: "How we cut our cold launch time by 60%",
                    topic: "devlog",
                    content: "Spent the week profiling our app's startup with *Instruments* and found we were doing way too much work on the main thread before the first frame. Full write-up with benchmarks below.",
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
                reactions: .init(mine: ["🔥"], counts: ["🚀": 2, "🔥": 2]),
            ),
            .init(
                data: .init(
                    id: "2",
                    title: "Settling a team debate",
                    topic: "SwiftUI",
                    content: "We keep going back and forth on this in code review, so let's put it to a vote. Which layout container do you reach for first?",
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
                reactions: .init(mine: [], counts: [:]),
            ),
            .init(
                data: .init(
                    id: "3",
                    title: nil,
                    topic: "Testing",
                    content: "Migrated our whole suite to Swift Testing this sprint and the parameterized tests alone made it worth it. Here's a 30-second clip of the new run in action.",
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
                reactions: .init(mine: ["👍"], counts: ["👍": 4, "🎉": 1]),
            ),
            .init(
                data: .init(
                    id: "4",
                    title: "Finally deleted the last of our Combine code",
                    topic: nil,
                    content: "Two years after we started, the networking layer is now 100% async/await. Callback pyramids gone, cancellation is trivial, and the diff removed more lines than it added. What's everyone else standardizing on these days?",
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
                reactions: .init(mine: [], counts: [:]),
            ),
            .init(
                data: .init(
                    id: "5",
                    title: nil,
                    topic: nil,
                    content: """
                        A few Markdown tricks I lean on for writing clear posts
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
                reactions: .init(mine: [], counts: [:]),
            ),
        ]
    }
}
