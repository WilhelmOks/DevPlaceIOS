import Foundation
import DevPlaceSwiftSDK

extension Reactions {
    func toggling(_ emoji: String) -> Reactions {
        if mine.contains(emoji) {
            var newCounts = counts
            let newCount = (newCounts[emoji] ?? 1) - 1
            if newCount > 0 {
                newCounts[emoji] = newCount
            } else {
                newCounts[emoji] = nil
            }
            return Reactions(mine: mine.filter { $0 != emoji }, counts: newCounts)
        } else {
            var newCounts = counts
            newCounts[emoji] = (newCounts[emoji] ?? 0) + 1
            return Reactions(mine: mine + [emoji], counts: newCounts)
        }
    }
}

extension Post {
    func replacingReactions(_ newReactions: Reactions) -> Post {
        Post(
            data: data,
            author: author,
            myVote: myVote,
            commentCount: commentCount,
            recentComments: recentComments,
            bookmarked: bookmarked,
            attachments: attachments,
            poll: poll,
            reactions: newReactions,
        )
    }
}

extension Comment {
    func replacingReactions(_ newReactions: Reactions, children: [Comment]) -> Comment {
        Comment(
            data: data,
            author: author,
            myVote: myVote,
            votes: votes,
            attachments: attachments,
            children: children,
            reactions: newReactions,
        )
    }
}

extension Array where Element == Comment {
    func updatingReaction(commentId: String, emoji: String) -> [Comment] {
        map { comment in
            let updatedChildren = comment.children.updatingReaction(commentId: commentId, emoji: emoji)
            if comment.data.id == commentId {
                return comment.replacingReactions(comment.reactions.toggling(emoji), children: updatedChildren)
            } else {
                return comment.replacingChildren(updatedChildren)
            }
        }
    }
}
