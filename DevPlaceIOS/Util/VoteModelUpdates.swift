import Foundation
import DevPlaceSwiftSDK

extension Feed {
    func replacingPosts(_ newPosts: [Post]) -> Feed {
        Feed(
            posts: newPosts,
            currentTab: currentTab,
            currentTopic: currentTopic,
            search: search,
            nextCursor: nextCursor,
            totalMembers: totalMembers,
            postsToday: postsToday,
            totalProjects: totalProjects,
            totalGists: totalGists,
            topAuthors: topAuthors,
        )
    }
}

extension Post {
    func replacingRecentComments(_ newComments: [Comment]) -> Post {
        Post(
            data: data,
            author: author,
            myVote: myVote,
            commentCount: commentCount,
            recentComments: newComments,
            bookmarked: bookmarked,
            attachments: attachments,
            poll: poll,
        )
    }
}

extension PostDetail {
    func with(myVote: Vote? = nil, starCount: Int? = nil, comments: [Comment]? = nil) -> PostDetail {
        PostDetail(
            post: post,
            author: author,
            isOwner: isOwner,
            starCount: starCount ?? self.starCount,
            myVote: myVote ?? self.myVote,
            comments: comments ?? self.comments,
            attachments: attachments,
            bookmarked: bookmarked,
            poll: poll,
            commentCount: commentCount,
            relatedPosts: relatedPosts,
            topics: topics,
        )
    }
}

extension Array where Element == Comment {
    func updatingVote(commentId: String, vote: Vote) -> [Comment] {
        map { comment in
            let updatedChildren = comment.children.updatingVote(commentId: commentId, vote: vote)
            if comment.data.id == commentId {
                return comment.applyingVote(vote, children: updatedChildren)
            } else {
                return comment.replacingChildren(updatedChildren)
            }
        }
    }
}

extension Comment {
    func applyingVote(_ newVote: Vote, children: [Comment]) -> Comment {
        var up = votes.up
        var down = votes.down
        switch myVote {
        case .up: up -= 1
        case .down: down -= 1
        case .none: break
        }
        switch newVote {
        case .up: up += 1
        case .down: down += 1
        case .none: break
        }
        return Comment(
            data: data,
            author: author,
            myVote: newVote,
            votes: Comment.Votes(up: up, down: down),
            attachments: attachments,
            children: children,
        )
    }
    
    func replacingChildren(_ newChildren: [Comment]) -> Comment {
        Comment(
            data: data,
            author: author,
            myVote: myVote,
            votes: votes,
            attachments: attachments,
            children: newChildren,
        )
    }
}
