import DevPlaceSwiftSDK

extension AppState {
    func updatePostVoteInFeed(postId: String, vote: Vote, count: Int) {
        guard let currentFeed = feed else { return }
        guard currentFeed.posts.contains(where: { $0.data.id == postId }) else { return }
        let updatedPosts = currentFeed.posts.map { post -> Post in
            guard post.data.id == postId else { return post }
            return Post(
                data: Post.Data(
                    id: post.data.id,
                    title: post.data.title,
                    topic: post.data.topic,
                    content: post.data.content,
                    slug: post.data.slug,
                    userId: post.data.userId,
                    stars: count,
                    image: post.data.image,
                    createdAt: post.data.createdAt,
                    updatedAt: post.data.updatedAt,
                ),
                author: post.author,
                myVote: vote,
                commentCount: post.commentCount,
                recentComments: post.recentComments,
                bookmarked: post.bookmarked,
                attachments: post.attachments,
                poll: post.poll,
                reactions: post.reactions,
            )
        }
        feed = Feed(
            posts: updatedPosts,
            currentTab: currentFeed.currentTab,
            currentTopic: currentFeed.currentTopic,
            search: currentFeed.search,
            nextCursor: currentFeed.nextCursor,
            totalMembers: currentFeed.totalMembers,
            postsToday: currentFeed.postsToday,
            totalProjects: currentFeed.totalProjects,
            totalGists: currentFeed.totalGists,
            topAuthors: currentFeed.topAuthors,
        )
    }
    
    func updateCommentVoteInFeed(commentId: String, vote: Vote) {
        guard let currentFeed = feed else { return }
        let updatedPosts = currentFeed.posts.map { post in
            post.replacingRecentComments(post.recentComments.updatingVote(commentId: commentId, vote: vote))
        }
        feed = currentFeed.replacingPosts(updatedPosts)
    }
    
    /// Performs an optimistic upvote toggle: if the current vote is already `.up` it is removed,
    /// otherwise it becomes `.up`. The backend `vote` endpoint toggles, so the selected value sent
    /// is always `.up`. `apply` is called with the new optimistic vote, and again with the previous
    /// vote to revert if the request fails.
    func performVoteToggle(
        targetType: TargetType,
        targetId: String,
        currentVote: Vote,
        api: DevPlaceApi,
        apply: (Vote) -> Void,
    ) async {
        let newVote: Vote = currentVote == .up ? .none : .up
        apply(newVote)
        do {
            try await api.vote(targetType: targetType, targetId: targetId, vote: .up)
        } catch {
            apply(currentVote)
            dlog("Double-tap vote failed: \(error)")
        }
    }
}
