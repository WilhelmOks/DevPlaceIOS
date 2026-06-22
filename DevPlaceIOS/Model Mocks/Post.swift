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
                    createdAt: Date().addingTimeInterval(-30),
                    updatedAt: Date().addingTimeInterval(-15),
                ),
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
                    createdAt: Date().addingTimeInterval(-30),
                    updatedAt: nil,
                ),
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
                    createdAt: Date().addingTimeInterval(-60),
                    updatedAt: nil,
                ),
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
                    createdAt: Date().addingTimeInterval(-60 * 60),
                    updatedAt: nil,
                ),
            ),
            .init(
                data: .init(
                    id: "5",
                    title: nil,
                    topic: nil,
                    content: "content 5",
                    slug: nil,
                    userId: "u1",
                    stars: 1337,
                    createdAt: Date().addingTimeInterval(-60 * 60 * 24),
                    updatedAt: nil,
                ),
            ),
        ]
    }
}
