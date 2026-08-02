import SwiftUI

struct DevPlaceTextEditor: View {
    enum SizeMode {
        case fill
        case resizable
    }

    @Binding var text: String
    var placeholder: String = ""
    var sizeMode: SizeMode = .resizable
    var initialLineCount: Int?
    var animatesHeightChanges: Bool = false
    var initialHeight: CGFloat?
    var backgroundColor: Color = .BG_1

    @State private var height: CGFloat = 0
    @State private var singleLineHeight: CGFloat = 0
    @State private var didInitializeHeight = false
    @State private var dragStartHeight: CGFloat?

    @ScaledMetric(relativeTo: .body) private var estimatedLineHeight: CGFloat = 21

    private let resizeSpaceName = "devPlaceTextEditorResize"
    private let resizeGrabHeight: CGFloat = 24

    var body: some View {
        BoxView(
            backgroundColor: backgroundColor,
            borderOpacity: 0.5,
            cornerSize: .big,
            paddingSize: .none,
        ) {
            sizedEditor()
                .coordinateSpace(.named(resizeSpaceName))
                .simultaneousGesture(
                    resizeGesture,
                    including: sizeMode == .resizable ? .all : .subviews,
                )
                .overlay {
                    heightMeasurement()
                }
                .overlay(alignment: .bottomTrailing) {
                    if sizeMode == .resizable {
                        resizeGripIndicator()
                    }
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
                .frame(height: resolvedHeight)
                .animation(heightAnimation, value: resolvedHeight)
        }
    }

    private var resolvedHeight: CGFloat {
        if !didInitializeHeight {
            if let initialHeight {
                return initialHeight
            }
            if animatesHeightChanges {
                return estimatedContentHeight
            }
        }
        return max(singleLineHeight, height)
    }

    private var estimatedContentHeight: CGFloat {
        let lineCount = text.reduce(into: 1) { count, character in
            if character == "\n" { count += 1 }
        }
        let verticalPadding: CGFloat = 20
        return CGFloat(lineCount) * estimatedLineHeight + verticalPadding
    }

    private var heightAnimation: Animation? {
        guard animatesHeightChanges, dragStartHeight == nil else { return nil }
        return .smooth(duration: 0.25)
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

    @ViewBuilder private func resizeGripIndicator() -> some View {
        ResizeGrip()
            .stroke(.FG_2.opacity(0.7), style: .init(lineWidth: 1.5, lineCap: .round))
            .frame(width: 10, height: 10)
            .padding(8)
            .allowsHitTesting(false)
    }

    private var resizeGesture: some Gesture {
        DragGesture(coordinateSpace: .named(resizeSpaceName))
            .onChanged { value in
                let currentHeight = max(singleLineHeight, height)
                if dragStartHeight == nil {
                    guard value.startLocation.y >= currentHeight - resizeGrabHeight else { return }
                    dragStartHeight = currentHeight
                }
                guard let start = dragStartHeight else { return }
                height = max(singleLineHeight, start + value.translation.height)
            }
            .onEnded { _ in
                dragStartHeight = nil
            }
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
