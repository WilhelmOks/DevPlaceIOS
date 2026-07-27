import SwiftUI

struct DevPlaceTextEditor: View {
    enum SizeMode {
        case fill
        case resizable
    }

    @Binding var text: String
    var placeholder: String = ""
    var sizeMode: SizeMode = .fill
    var initialLineCount: Int?

    @State private var height: CGFloat = 0
    @State private var singleLineHeight: CGFloat = 0
    @State private var didInitializeHeight = false
    @State private var dragStartHeight: CGFloat?

    var body: some View {
        sizedEditor()
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.FG_2.opacity(0.5))
                    .fill(.BG_1)
            }
            .overlay {
                heightMeasurement()
            }
            .overlay(alignment: .bottomTrailing) {
                if sizeMode == .resizable {
                    resizeHandle()
                }
            }
            .onPreferenceChange(ContentHeightKey.self) { value in
                guard value > 0, !didInitializeHeight else { return }
                height = value
                didInitializeHeight = true
            }
            .onPreferenceChange(LineHeightKey.self) { value in
                singleLineHeight = value
            }
    }

    @ViewBuilder private func sizedEditor() -> some View {
        switch sizeMode {
        case .fill:
            editorContent()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading,
                )
        case .resizable:
            editorContent()
                .frame(
                    maxWidth: .infinity,
                    alignment: .topLeading,
                )
                .frame(height: max(singleLineHeight, height))
        }
    }

    @ViewBuilder private func editorContent() -> some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.FG_2.opacity(0.5))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 5)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
    }

    @ViewBuilder private func resizeHandle() -> some View {
        ResizeGrip()
            .stroke(.FG_2.opacity(0.7), style: .init(lineWidth: 1.5, lineCap: .round))
            .frame(width: 10, height: 10)
            .padding(8)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        let start = dragStartHeight ?? max(singleLineHeight, height)
                        dragStartHeight = start
                        height = max(singleLineHeight, start + value.translation.height)
                    }
                    .onEnded { _ in
                        dragStartHeight = nil
                    }
            )
    }

    private var initialMeasurementString: String {
        if let initialLineCount, initialLineCount > 0 {
            return String(repeating: "\n", count: initialLineCount - 1)
        }
        return text.isEmpty ? " " : text
    }

    @ViewBuilder private func heightMeasurement() -> some View {
        ZStack {
            measuringText(for: initialMeasurementString)
                .background {
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ContentHeightKey.self,
                            value: geometry.size.height,
                        )
                    }
                }

            measuringText(for: " ")
                .background {
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: LineHeightKey.self,
                            value: geometry.size.height,
                        )
                    }
                }
        }
        .hidden()
    }

    @ViewBuilder private func measuringText(for string: String) -> some View {
        Text(string)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct ResizeGrip: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step = rect.width / 3
        for line in 1...2 {
            let offset = step * CGFloat(line)
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY + offset))
            path.addLine(to: CGPoint(x: rect.minX + offset, y: rect.maxY))
        }
        return path
    }
}

private struct ContentHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct LineHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview("resizable") {
    @Previewable @State var resizable = "This is a resizable text editor.\nDrag the corner grip to change its height."
    ScrollView {
        VStack(alignment: .leading, spacing: 20) {
            DevPlaceTextEditor(
                text: $resizable,
                placeholder: "Write something…",
                sizeMode: .resizable,
                initialLineCount: nil,
            )
        }
        .padding()
    }
    .background {
        Color.BG_2.ignoresSafeArea()
    }
}

#Preview("space filling") {
    @Previewable @State var filling = ""
    
    DevPlaceTextEditor(
        text: $filling,
        placeholder: "Write something…",
        sizeMode: .fill,
    )
    .padding()
    .background {
        Color.BG_2.ignoresSafeArea()
    }
}
