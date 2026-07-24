import SwiftUI
import MarkdownUI
import DevPlaceSwiftSDK

struct PostContentView: View {
    let title: String?
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                let markdownTitle = LocalizedStringKey(title)
                Text(markdownTitle)
                    .lineSpacing(0)
                    .font(.title)
            }
            
            Markdown(content)
                .markdownTheme(.devPlace)
                .markdownSoftBreakMode(.lineBreak)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
