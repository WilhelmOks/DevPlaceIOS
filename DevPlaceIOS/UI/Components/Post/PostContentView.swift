import SwiftUI
import MarkdownUI
import DevPlaceSwiftSDK

//TODO: rename to something more generic because it's not just for posts.
struct PostContentView: View {
    let topic: String?
    let title: String?
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let topic {
                CapsuleLabel(text: topic)
            }
            
            if let title {
                let markdownTitle = LocalizedStringKey(title)
                Text(markdownTitle)
                    .lineSpacing(0)
                    .font(.title)
                    .selectableTextPopover(title)
            }
            
            Markdown(content)
                .markdownTheme(.devPlace)
                .markdownSoftBreakMode(.lineBreak)
                .selectableTextPopover(content)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
