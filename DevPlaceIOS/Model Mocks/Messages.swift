import Foundation
import DevPlaceSwiftSDK

extension User {
    static var mockAlice: Self {
        .init(
            id: "u10",
            username: "alice",
            avatarSeed: nil,
            role: .member,
            bio: "Building things on the web.",
            location: "Berlin, Germany",
            gitLink: "https://github.com/alice",
            website: "",
            level: 42,
            xp: 9001,
            stars: 128,
            createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 400),
        )
    }

    static var mockBob: Self {
        .init(
            id: "u11",
            username: "bob",
            avatarSeed: nil,
            role: .member,
            bio: "Backend enthusiast.",
            location: "Reykjavík, Iceland",
            gitLink: "https://github.com/bob",
            website: "",
            level: 7,
            xp: 320,
            stars: 12,
            createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 120),
        )
    }

    static var mockCarol: Self {
        .init(
            id: "u12",
            username: "carol",
            avatarSeed: nil,
            role: .member,
            bio: "Shipping features.",
            location: "Lisbon, Portugal",
            gitLink: "https://github.com/carol",
            website: "",
            level: 19,
            xp: 1500,
            stars: 44,
            createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 90),
        )
    }
}

extension Message {
    static func mock(
        id: String,
        from sender: User,
        to receiver: User,
        content: String,
        isMine: Bool,
        read: Bool,
        minutesAgo: Double,
        attachments: [Attachment] = [],
    ) -> Message {
        .init(
            data: .init(
                id: id,
                senderId: sender.id,
                receiverId: receiver.id,
                content: content,
                read: read,
                createdAt: Date().addingTimeInterval(-60 * minutesAgo),
            ),
            sender: sender,
            isMine: isMine,
            attachments: attachments,
        )
    }
}

extension MessagesInbox {
    private static func iso(secondsAgo: TimeInterval) -> String {
        ISO8601DateFormatter().string(from: Date().addingTimeInterval(-secondsAgo))
    }

    static var mockInbox: MessagesInbox {
        .init(
            conversations: [
                Conversation(
                    otherUser: .mockAlice,
                    lastMessage: "Sounds good, let's ship it!",
                    lastMessageAt: iso(secondsAgo: 60 * 60),
                    unread: false,
                ),
                Conversation(
                    otherUser: .mockBob,
                    lastMessage: "Could you review my pull request?",
                    lastMessageAt: iso(secondsAgo: 60 * 90),
                    unread: true,
                ),
                Conversation(
                    otherUser: .mockCarol,
                    lastMessage: "Here's the link: https://example.com/demo",
                    lastMessageAt: iso(secondsAgo: 60 * 60 * 24 * 4),
                    unread: false,
                ),
            ],
            messages: [],
            otherUser: .mockAlice,
            currentConversation: "",
            search: "",
            otherOnline: false,
            otherLastSeen: "2m ago",
        )
    }

    static var mockConversation: MessagesInbox {
        let me = User.mock
        let other = User.mockAlice
        return .init(
            conversations: mockInbox.conversations,
            messages: [
                .mock(id: "m1", from: me, to: other, content: "Hey, how's it going?", isMine: true, read: true, minutesAgo: 16 * 60),
                .mock(id: "m2", from: other, to: me, content: "Pretty good! Working on the new feature.", isMine: false, read: true, minutesAgo: 15 * 60),
                .mock(id: "m3", from: other, to: me, content: "It supports **markdown** and even *emphasis*.", isMine: false, read: true, minutesAgo: 14 * 60),
                .mock(id: "m4", from: other, to: me, content: "I should really finish it today.", isMine: false, read: true, minutesAgo: 3 * 60),
                .mock(
                    id: "m5",
                    from: other,
                    to: me,
                    content: "Here's a quick screenshot.",
                    isMine: false,
                    read: true,
                    minutesAgo: 2 * 60,
                    attachments: [
                        .init(
                            id: "a1",
                            filename: "screenshot.jpg",
                            url: "https://picsum.photos/id/1015/600/400",
                            size: nil,
                            isImage: true,
                            isVideo: false,
                            mimeType: "image/jpeg",
                            createdAt: Date().addingTimeInterval(-60 * 60 * 2),
                            canModify: false,
                        ),
                    ],
                ),
                .mock(id: "m6", from: me, to: other, content: "Looks great!", isMine: true, read: true, minutesAgo: 60),
                .mock(id: "m7", from: other, to: me, content: "Thanks 😄", isMine: false, read: false, minutesAgo: 55),
                .mock(id: "m8", from: me, to: other, content: "Sounds good, let's ship it!", isMine: true, read: false, minutesAgo: 1),
            ],
            otherUser: other,
            currentConversation: "c-alice",
            search: "",
            otherOnline: true,
            otherLastSeen: "just now",
        )
    }
}
