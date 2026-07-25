import DevPlaceSwiftSDK

extension AppState {
    func updatePostReactionInFeed(postId: String, emoji: String) {
        guard let currentFeed = feed else { return }
        guard currentFeed.posts.contains(where: { $0.data.id == postId }) else { return }
        let updatedPosts = currentFeed.posts.map { post -> Post in
            guard post.data.id == postId else { return post }
            return post.replacingReactions(post.reactions.toggling(emoji))
        }
        feed = currentFeed.replacingPosts(updatedPosts)
    }
    
    func updateCommentReactionInFeed(commentId: String, emoji: String) {
        guard let currentFeed = feed else { return }
        let updatedPosts = currentFeed.posts.map { post in
            post.replacingRecentComments(post.recentComments.updatingReaction(commentId: commentId, emoji: emoji))
        }
        feed = currentFeed.replacingPosts(updatedPosts)
    }
    
    /// Performs an optimistic reaction toggle. The `react` endpoint toggles: submitting an emoji the
    /// user already reacted with removes it, and a new emoji adds it. `apply` toggles the local model
    /// and is called once optimistically, then again to revert if the request fails.
    func performReactionToggle(
        targetType: TargetType,
        targetId: String,
        emoji: String,
        api: DevPlaceApi,
        apply: () -> Void,
    ) async {
        apply()
        do {
            try await api.react(targetType: targetType, targetId: targetId, emoji: emoji)
        } catch {
            apply()
            dlog("Reaction toggle failed: \(error)")
        }
    }
}
