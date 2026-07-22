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
                    slug: nil,
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
                attachments: [],
                poll: nil,
            ),
            .init(
                data: .init(
                    id: "2",
                    title: "title 2",
                    topic: "topic 2",
                    content: "content 2",
                    slug: nil,
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
                poll: nil,
            ),
            .init(
                data: .init(
                    id: "3",
                    title: nil,
                    topic: "topic 3",
                    content: "content 3",
                    slug: nil,
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
                attachments: [],
                poll: nil,
            ),
            .init(
                data: .init(
                    id: "4",
                    title: "title 4",
                    topic: nil,
                    content: "content 4",
                    slug: nil,
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
                poll: nil,
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
                    slug: nil,
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
                attachments: [],
                poll: nil,
            ),
        ]
    }
}
