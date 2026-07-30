import SwiftUI
import DevPlaceSwiftSDK

struct PostFooterView: View {
    let targetId: String
    let starCount: Int
    let currentVote: Vote
    let reactions: Reactions
    let onReact: (String) -> Void
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    @State private var isConfirmingDelete = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            HStack(spacing: 12) {
                VoteView(targetType: .post, targetId: targetId, count: starCount, currentVote: currentVote)
                
                ReactionsBar(reactions: reactions, onReact: onReact)
                
                Spacer(minLength: 0)

                HStack(spacing: 24) {
                    if let onEdit {
                        editButton(onEdit: onEdit)
                    }

                    if onDelete != nil {
                        deleteButton()
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func editButton(onEdit: @escaping () -> Void) -> some View {
        Button {
            onEdit()
        } label: {
            Label("Edit post", systemImage: "pencil")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.FG_1)
    }
    
    @ViewBuilder private func deleteButton() -> some View {
        Button {
            isConfirmingDelete = true
        } label: {
            Label("Delete post", systemImage: "trash")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.FG_1)
        .confirmationDialog(
            "Delete this post?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible,
        ) {
            Button("Delete", role: .destructive) {
                onDelete?()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
