struct PostDestination: Hashable, Identifiable {
    let slug: String
    let scrollToCommentId: String?

    var id: Self { self }
}
