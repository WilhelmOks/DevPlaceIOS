import SwiftUI

struct EmojiPicker: View {
    let onPick: (String) -> Void
    
    @Bindable private var appSettings = AppSettingsStore.shared
    
    @State private var searchText = ""
    
    private let cellSize: CGFloat = 44
    private let cellSpacing: CGFloat = 4
    private let horizontalPadding: CGFloat = 8
    private let emojiSize: CGFloat = 30
    
    var body: some View {
        VStack(spacing: 0) {
            searchField()
            
            GeometryReader { geometry in
                let columns = columnCount(for: geometry.size.width)
                
                if searchText.isEmpty {
                    categorizedList(columns: columns)
                } else {
                    searchResults(columns: columns)
                }
            }
        }
        .background(Color.BG_2)
    }
    
    private func columnCount(for width: CGFloat) -> Int {
        let available = width - horizontalPadding * 2 + cellSpacing
        return max(1, Int(available / (cellSize + cellSpacing)))
    }
    
    @ViewBuilder private func searchField() -> some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.FG_2)
            
            TextField("Search Emoji", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.FG_2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color.BG_1, in: RoundedRectangle(cornerRadius: 10))
        .padding()
    }
    
    @ViewBuilder private func categorizedList(columns: Int) -> some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if !appSettings.recentEmojis.isEmpty {
                            emojiSection(title: "Recent", emojis: appSettings.recentEmojis, columns: columns)
                        }
                        
                        ForEach(EmojiCatalog.categories) { category in
                            emojiSection(title: category.name, emojis: category.emojis, columns: columns)
                                .id(category.id)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 8)
                }
                .frame(maxHeight: .infinity)
                
                categoryBar(proxy: proxy)
            }
        }
    }
    
    @ViewBuilder private func searchResults(columns: Int) -> some View {
        let results = EmojiCatalog.emojis(matching: searchText)
        ScrollView {
            if results.isEmpty {
                Text("No emoji found")
                    .foregroundStyle(Color.FG_2)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else {
                VStack(alignment: .leading, spacing: cellSpacing) {
                    emojiRows(for: results, columns: columns)
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
    }
    
    @ViewBuilder private func emojiSection(title: String, emojis: [String], columns: Int) -> some View {
        VStack(alignment: .leading, spacing: cellSpacing) {
            sectionHeader(title)
            
            emojiRows(for: emojis, columns: columns)
        }
    }
    
    @ViewBuilder private func emojiRows(for emojis: [String], columns: Int) -> some View {
        ForEach(Array(emojis.chunked(into: columns).enumerated()), id: \.offset) { _, row in
            HStack(spacing: cellSpacing) {
                ForEach(row, id: \.self) { emoji in
                    emojiButton(emoji)
                }
                
                Spacer(minLength: 0)
            }
        }
    }
    
    @ViewBuilder private func categoryBar(proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 0) {
            ForEach(EmojiCatalog.categories) { category in
                Button {
                    withAnimation {
                        proxy.scrollTo(category.id, anchor: .top)
                    }
                } label: {
                    Image(systemName: category.symbolName)
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.FG_2)
            }
        }
        .background(Color.BG_1)
    }
    
    @ViewBuilder private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.FG_2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
    }
    
    @ViewBuilder private func emojiButton(_ emoji: String) -> some View {
        Button {
            onPick(emoji)
            appSettings.recordEmojiPick(emoji)
        } label: {
            Text(emoji)
                .font(.system(size: emojiSize))
                .frame(width: cellSize, height: cellSize)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EmojiPicker { emoji in
        dlog("Picked \(emoji)")
    }
}
