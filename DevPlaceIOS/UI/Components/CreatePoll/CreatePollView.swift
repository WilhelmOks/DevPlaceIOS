import SwiftUI
import DevPlaceSwiftSDK

struct CreatePollView: View {
    @Binding var question: String
    @Binding var options: [String]

    private let minOptionsCount = 2

    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case question
        case option(Int)
    }

    private var canAddOption: Bool {
        options.count < DevPlaceConstants.maxPollOptionsCount
    }

    private var canRemoveOption: Bool {
        options.count > minOptionsCount
    }

    var body: some View {
        BoxView {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Poll question", text: $question)
                    .textFieldStyle(.devPlace)
                    .focused($focusedField, equals: .question)

                Divider()
                    .overlay(Color.FG_2.opacity(0.25))

                ForEach(options.indices, id: \.self) { index in
                    optionRow(index: index)
                }

                if canAddOption {
                    addOptionButton()
                }
            }
        }
        .onSubmit(advanceFocus)
    }

    @ViewBuilder private func optionRow(index: Int) -> some View {
        HStack(spacing: 10) {
            TextField("Option \(index + 1)", text: $options[index])
                .textFieldStyle(.devPlace)
                .focused($focusedField, equals: .option(index))

            if canRemoveOption {
                Button {
                    removeOption(at: index)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder private func addOptionButton() -> some View {
        Button {
            options.append("")
        } label: {
            Label("Add option", systemImage: "plus")
        }
    }

    private func removeOption(at index: Int) {
        guard canRemoveOption else { return }
        options.remove(at: index)
    }

    private func advanceFocus() {
        switch focusedField {
        case .question:
            focusedField = .option(0)
        case .option(let index) where index + 1 < options.count:
            focusedField = .option(index + 1)
        default:
            focusedField = nil
        }
    }
}

#Preview {
    @Previewable @State var question = ""
    @Previewable @State var options = ["", "", "", "", ""]

    CreatePollView(question: $question, options: $options)
        .padding()
        .background(Color.BG_1)
}
