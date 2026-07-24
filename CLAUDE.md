# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

Two Swift modules in one repo:

- **`DevPlaceIOS/`** — the SwiftUI iOS app (Xcode project at `DevPlaceIOS.xcodeproj`). Source under `DevPlaceIOS/DevPlaceIOS/`.
- **`DevPlaceSwiftSDK/`** — a local Swift Package the app links against. Will be extracted to its own repo eventually; for now it co-lives here for fast iteration. Source under `DevPlaceSwiftSDK/Sources/DevPlaceSwiftSDK/`.

The SDK has one external dependency that's relevant: `KreeRequest` (HTTP client wrapper used by `DevPlaceRequest`).

## Build, test, diagnostics

Always prefer the `xcode-tools` MCP server over `xcodebuild`:

- `BuildProject` — full Xcode build. Slow; use to confirm compilation across the whole project.
- `XcodeRefreshCodeIssuesInFile` — fast per-file diagnostics. Use after edits to catch type errors, unresolved symbols, missing imports. First call after creating a file sometimes returns `error 5` — retry once.
- `RunAllTests` / `RunSomeTests` / `GetTestList` — test execution (Testing framework, not XCTest, per project convention).
- `ExecuteSnippet` — REPL-style code execution in the context of a file. Useful for trying out small ideas without full builds.

## Important: SwiftPM vs Xcode project file paths

Files under **`DevPlaceSwiftSDK/Sources/...`** are *not* tracked as Xcode project references — SwiftPM discovers them automatically. `XcodeWrite` will fail there with `"directory insertion mode '“folders”'"`. Use `Write` / `Edit` / `Bash` for SDK source files. (`XcodeRead` and `XcodeRefreshCodeIssuesInFile` do work on those paths.)

Files under **`DevPlaceIOS/DevPlaceIOS/...`** are tracked Xcode project references — use `XcodeWrite` / `XcodeUpdate` so new files register with the project.

## Architecture

### SDK: domain model pattern

Every model in `DevPlaceSwiftSDK/Sources/DevPlaceSwiftSDK/Models/` follows the same three-layer shape:

1. A public domain type (`Hashable, Sendable`, `Identifiable` where applicable) with camelCase Swift property names and a public memberwise `init`.
2. A nested `CodingData: Decodable` in an extension, with property names matching the JSON exactly (snake_case preserved, e.g. `user_uid`, `created_at`).
3. A `var decoded: <Domain>` on the `CodingData` that produces the domain type.

When the JSON wraps a core object (e.g. `Post` = `{ "post": {...}, "author": ..., ... }`), the domain splits into `Domain` (wrapper-level fields) and `Domain.Data` (core fields), with their `CodingData` types nested correspondingly. Flat objects (e.g. `User`) skip the inner `Data`. See `Post.swift` and `User.swift` for the canonical examples.

The `devplace-model-from-json` skill encodes this convention — invoke it when extending or adding models from a JSON sample, including how to handle nulls/empty arrays/empty objects (comment them out with a "type unknown" note rather than guessing).

JSON dates use ISO8601 with optional fractional seconds (`JSONDecoder.devPlace` in `DevPlaceJSONCoder.swift`).

When adding a new `DevPlaceRequest` call with a request body, prefer JSON body encoding (`contentType: .jsonBody` + `request.requestJson(config:json:)` with a nested `struct Body: Encodable`) over form/url-encoding — even when the backend docs show a `-d`/form-encoded example. The backend accepts JSON for these endpoints. Only fall back to url-encoded/string bodies if JSON turns out not to work for a specific endpoint.

### App: API protocol + Environment injection

`DevPlaceApi` (`DevPlaceIOS/Request/API/DevPlaceApi.swift`) is the abstraction every screen sees. Two implementations:

- `ProdDevPlaceApi` — wraps `DevPlaceSwiftSDK.DevPlaceRequest`, calls the real `https://devplace.net/` backend, manages token refresh via `refreshTokenIfNeeded()` before each authenticated call.
- `MockDevPlaceApi` — returns `Feed.mock` etc., used by previews and offline development.

Both are exposed via `EnvironmentValues.api` (`DevPlaceApi+Environment.swift`). Default is `.prod`. Views read it with `@Environment(\.api) var api` and pass it into their ViewModel's `init`. Previews swap in `.mock` by setting `.environment(\.api, .mock)` on the root view.

### App: View / ViewModel pattern

The `TemplateView` pair under `DevPlaceIOS/UI/Template/` is the canonical shape:

- `<Name>View: View` — reads `@Environment(\.api)`, constructs the ViewModel, renders a private `<Name>ViewContent`.
- `private struct <Name>ViewContent: View` — holds `@State var viewModel`, builds the UI in `content()`.
- `extension <Name>View { @Observable final class ViewModel { ... } }` in `<Name>View+ViewModel.swift` — holds `let api: DevPlaceApi`, mutable `@Observable` state, async methods that call the API.

Use the `devplace-swiftui-scaffold` skill to generate new screens conforming to this pattern.

### App-wide state

Two `@Observable final class` singletons:

- `AppState.shared` — runtime state (`token: AuthToken?`, `feed: Feed?`). Mutated from API implementations and ViewModels.
- `UserSessionStore.shared` — persists `email` / `password` to the iOS Keychain via `SwiftKeychainWrapper`. The app's `init` reads these on launch and silently re-logs in if present.

`dlog(...)` (`Logging.swift`) is a `#if DEBUG`-gated print helper used throughout. Use it instead of `print`.

### Styling tokens

Color tokens `Color.BG_1`, `Color.BG_2`, `Color.FG_1`, `Color.FG_2` are defined in `Assets.xcassets`. The `.screenStyle(...)` view modifier (`UI/Style/Screen/ScreenStyleModifier.swift`) is the standard way to apply screen-level background + foreground.

## Conventions

- **Testing framework:** Swift Testing (`import Testing`, `@Test`), not XCTest. UI tests use `XCUIAutomation`.
- **Concurrency:** Swift `async`/`await` only — do not introduce `Combine`. (The existing `import Combine` in some files is vestigial and can be removed.)
- **Swift 6 trailing commas:** the project uses trailing commas in multi-line parameter and argument lists. Preserve that style when editing.
- **Indentation:** 4 spaces.
- **leading whitespace** whitespace on empty lines is allowed. Don't remove it between indented code. Add it to match the level of indentation when you create new code.
- **Nested multi-line calls:** when an argument is itself a multi-line call, the inner call's opening `(` goes on its own line — never stack `Outer(arg: .init(` on the same line. Each call's `(` opens after its own indent, arguments are indented one level in, and the closing `)` sits on its own line at the outer indent. Example:

    ```swift
    // Correct
    Outer(
        arg: .init(
            field: "value",
            other: 42,
        )
    )

    // Wrong — .init( piggybacked on the outer call's argument line
    Outer(arg: .init(
        field: "value",
        other: 42,
    ))
    ```
- **User preferences / settings:** always add to `AppSettingsStore` (`DevPlaceIOS/AppSettingsStore.swift`) with a `didSet`-persisted `UserDefaults` key, following the existing `appearance` / `showFeedAttachments` pattern. Don't invent parallel storage.
- **Naming interactions:** prefer "select"/"selected" over "tap"/"tapped" when naming interaction handlers, parameters, and state — users interact through means other than tapping (keyboard, VoiceOver, external input), so the more general term is more accurate. E.g. `select(optionId:)`, `selectedOptionId`, not `tap(optionId:)`, `tappedOptionId`.
- **Tap / press interactions:** default to native interactive components (`Button`, `NavigationLink`, `Toggle`, `Link`, etc.). Do not reach for gesture recognizers (`.onTapGesture`, `TapGesture`, `LongPressGesture`, etc.) unless the user explicitly asks for one — gesture recognizers bypass the accessibility affordances that native components provide (traits, focus, VoiceOver actions, hit-testing).

## Code philosophy

- Prioritize readability above all else.
- NO COMMENTS OR DOCSTRINGS in source files. Code must be self-documenting through clear naming and structure.

## Skills

Project-specific skills live under `.claude/skills/`:

- **`devplace-swiftui-scaffold`** — scaffold a new `<Name>View` + `<Name>View+ViewModel` pair.
- **`devplace-model-from-json`** — add/extend SDK models from a JSON sample using the `CodingData` pattern.

Invoke them by name via the Skill tool (or via `/<skill-name>` if the user types it).
