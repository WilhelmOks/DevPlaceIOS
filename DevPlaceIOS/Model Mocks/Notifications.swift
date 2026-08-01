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
                                id: "n0",
                                type: .message,
                                message: "null_void sent you a message",
                                read: false,
                                relatedId: "u2",
                                targetUrl: "/messages?with_uid=u2",
                                createdAt: Date().addingTimeInterval(-60 * 3),
                            ),
                            actor: .mock2,
                        ),
                        .init(
                            data: .init(
                                id: "n1",
                                type: nil,
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
                                type: .comment,
                                message: "cheeze_on_wheels commented on your post",
                                read: false,
                                relatedId: "c6",
                                targetUrl: "/posts/a-post-with-several-attachments#comment-c6",
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
                                type: nil,
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
                                type: .vote,
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
