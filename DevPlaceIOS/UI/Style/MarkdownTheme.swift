import SwiftUI
import MarkdownUI

extension Theme {
    static let devPlace = Theme()
        .code {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.85))
            BackgroundColor(.BG_1)
        }
        .blockquote { configuration in
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.FG_2)
                    .relativeFrame(width: .em(0.2))
                
                configuration.label
                    .markdownTextStyle { ForegroundColor(.FG_2) }
                    .relativePadding(.horizontal, length: .em(1))
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .codeBlock { configuration in
            ScrollView(.horizontal) {
                configuration.label
                    .fixedSize(horizontal: false, vertical: true)
                    .relativeLineSpacing(.em(0.225))
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(.em(0.85))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
            }
            .background(Color.BG_1)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .markdownMargin(top: 6, bottom: 16)
        }
}
