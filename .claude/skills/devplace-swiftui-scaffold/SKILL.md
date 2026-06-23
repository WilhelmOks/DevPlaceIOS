---
name: devplace-swiftui-scaffold
description: Scaffold a new SwiftUI screen in DevPlaceIOS following the project's TemplateView pattern. Creates `<Name>View.swift` and `<Name>View+ViewModel.swift` in `DevPlaceIOS/UI/Screens/<Name>/`. Use when the user asks to "scaffold", "create", or "make a new View/Screen" in this project.
---

# DevPlace SwiftUI Scaffold

Generate a new SwiftUI screen pair (`View` + `ViewModel`) following the project's established pattern, derived from `DevPlaceIOS/UI/Template/TemplateView.swift` and `TemplateView+ViewModel.swift`.

## Inputs

- **Name** (required): The base name of the screen (e.g. `Notifications`, `Profile`). Do NOT include the `View` suffix — the skill appends it. Passed as the skill argument.

If no Name is supplied, ask the user for it before proceeding.

## What this skill creates

For an input `Name`:

1. `DevPlaceIOS/UI/Screens/<Name>/<Name>View.swift`
2. `DevPlaceIOS/UI/Screens/<Name>/<Name>View+ViewModel.swift`

Before writing, verify the target directory does not already contain files with these names. If a conflict exists, ask the user how to proceed (overwrite, pick a different name, abort).

## File templates

### `<Name>View.swift`

```swift
import SwiftUI
import DevPlaceSwiftSDK

struct <Name>View: View {
    @Environment(\.api) var api
    
    var body: some View {
        <Name>ViewContent(viewModel: .init(api: api))
    }
}

private struct <Name>ViewContent: View {
    @State var viewModel: <Name>View.ViewModel
    
    var body: some View {
        content()
    }
    
    @ViewBuilder private func content() -> some View {
        
    }
}

#Preview {
    <Name>View()
}
```

### `<Name>View+ViewModel.swift`

```swift
import Foundation
import Observation
import Combine

extension <Name>View {
    @Observable final class ViewModel {
        let api: DevPlaceApi
        
        init(api: DevPlaceApi) {
            self.api = api
        }
    }
}
```

Replace every `<Name>` placeholder with the exact input name (preserve casing — PascalCase).

## Steps

1. Confirm `Name` is in PascalCase. If not, normalize and confirm with the user.
2. Check `DevPlaceIOS/UI/Screens/<Name>/` — create it if missing.
3. Write both files using the templates above.
4. After writing, briefly confirm the two file paths created. Don't summarize the contents — the user can read the diff.
5. Do NOT modify `MainView.swift`, `ContentView.swift`, navigation, or any other file. Wiring the new screen into navigation is a separate task.

## Out of scope

- Adding to navigation / tab bars
- Creating mocks, API endpoints, or model types
- Writing tests
- Running builds
