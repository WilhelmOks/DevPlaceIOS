import Foundation
import DevPlaceSwiftSDK

extension Notifications {
    static var mock: Self {
        .init(
            groups: [
                .init(
                    label: "Today",
                    entries: [
                        .init(
                            data: .init(
                                id: "n1",
                                type: "reaction",
                                message: "null_void reacted 🎉 to your post \"Shipping the new build system\"",
                                read: false,
                                relatedId: "p1",
                                targetUrl: "/posts/shipping-the-new-build-system",
                                createdAt: Date().addingTimeInterval(-60 * 8),
                            ),
                            actor: .mock2,
                        ),
                        .init(
                            data: .init(
                                id: "n2",
                                type: "comment",
                                message: "cheeze_on_wheels commented on your post",
                                read: false,
                                relatedId: "p2",
                                targetUrl: "/posts/late-night-refactor",
                                createdAt: Date().addingTimeInterval(-60 * 47),
                            ),
                            actor: .mock,
                        ),
                    ],
                ),
                .init(
                    label: "Earlier",
                    entries: [
                        .init(
                            data: .init(
                                id: "n3",
                                type: "follow",
                                message: "null_void started following you",
                                read: true,
                                relatedId: "u2",
                                targetUrl: "/users/null_void",
                                createdAt: Date().addingTimeInterval(-60 * 60 * 26),
                            ),
                            actor: .mock2,
                        ),
                        .init(
                            data: .init(
                                id: "n4",
                                type: "vote",
                                message: "cheeze_on_wheels upvoted your comment",
                                read: true,
                                relatedId: "c1",
                                targetUrl: "/posts/late-night-refactor",
                                createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 4),
                            ),
                            actor: .mock,
                        ),
                    ],
                ),
            ],
            nextCursor: nil,
        )
    }
}
