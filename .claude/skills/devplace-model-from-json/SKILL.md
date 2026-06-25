---
name: devplace-model-from-json
description: Add or extend Swift domain models in `DevPlaceSwiftSDK/Sources/DevPlaceSwiftSDK/Models/` from a (potentially incomplete) JSON response. Creates missing models, extends existing ones, and follows the project's `CodingData` decoding pattern. Use when the user asks to "add a model from JSON", "extend models from this response", or supplies a JSON payload to map into models.
---

# DevPlace Model From JSON

Add or extend the SDK's Swift domain models so they decode a given JSON response from the DevPlace REST API. Mirror the existing pattern in `DevPlaceSwiftSDK/Sources/DevPlaceSwiftSDK/Models/` (see `Post.swift`, `Feed.swift`, `User.swift`, `Comment.swift`, `AuthToken.swift`).

## Inputs

- **JSON data** (required): a sample response (or a fragment of one) from the DevPlace API. The user may paste it inline, attach a file, or give a file path.

If no JSON is supplied, ask the user for it before proceeding. Do not guess field names or shapes.

## The pattern

Every domain model has these layers:

1. **Domain type** — public, `Hashable, Sendable, Identifiable` where it has an id. Stored properties use camelCase Swift names. Has a public memberwise `init`.
2. **`CodingData` nested type** — `Decodable`, with property names matching the JSON exactly (snake_case kept as-is, e.g. `user_uid`, `created_at`). Lives in an `extension <Domain>`.
3. **`var decoded: <Domain>`** on the `CodingData` — converts the decoded payload to the domain type.

When the JSON has a wrapper object (e.g. `{"post": {...}, "author": {...}, ...}`), split into:
- `Domain` — represents the whole wrapper (has the wrapper-level fields)
- `Domain.Data` — represents the inner core object (its CodingData lives in `extension <Domain>.Data`)

When the JSON has no wrapper (e.g. `author` is just a flat object), the domain type is flat — no inner `Data` struct.

### Identifiable id convention

For wrapper types with an inner `Data`, `id` is namespaced: `var id: String { "<typename>:" + data.id }` (e.g. `"post:" + data.id`). For flat types, `id` is the natural identifier (e.g. `uid` mapped to `id`).

### Trailing commas

The project uses Swift 6 trailing commas in multi-line parameter and argument lists. Preserve that style.

## How to handle missing / ambiguous JSON

If a field's type cannot be determined from the sample:
- `null` values (e.g. `"poll": null`, `"avatar_seed": null`) — comment out the field in both the domain type and `CodingData`, with a note like `// null in sample - type unknown`.
- Empty arrays (e.g. `"attachments": []`) — comment out, with a note like `// empty array in sample - type unknown`. Do this even if the name strongly hints at a type; do not invent the element type from the field name.
- Empty objects (e.g. `"reactions": { "counts": {}, "mine": [] }`) — comment out, with a note.
- Nullable fields with non-null examples elsewhere in the payload that confirm a `String` (or other) type — model as `String?` (or that type). Only comment out when truly no type info exists.

When a field is conventionally a URL (e.g. `git_link`, `website`) but the JSON gives a `String`, keep it as `String`.

## Steps

1. Read the JSON the user provided.
2. Read the existing models in `DevPlaceSwiftSDK/Sources/DevPlaceSwiftSDK/Models/` to see what already exists and what shape they take.
3. For each top-level / nested object in the JSON:
   - If a matching model already exists, extend it: add new domain properties, new `CodingData` fields, and update `decoded` and the `init`. Preserve existing comments (like `//public let image: String?`).
   - If there is new type info from the provided json data about a property where a comment is due to previously missing type info, remove the comment and replace it with the correct property and type from newly provided info from the json data.
   - If no matching model exists, create a new file `<TypeName>.swift` in `DevPlaceSwiftSDK/Sources/DevPlaceSwiftSDK/Models/` following the pattern.
4. After writing, check diagnostics with `XcodeRefreshCodeIssuesInFile` for each touched/created file.
5. If extending a model's public `init` breaks downstream call sites (typically `DevPlaceIOS/Model Mocks/*.swift`), tell the user the mocks are now broken and ask whether to update them. Do not silently update mocks unless asked — that is a separate task handled by the user or a follow-up request.

## File writing

`DevPlaceSwiftSDK` is a local SwiftPM package — its Sources directory is not part of the Xcode project's file references. Use the regular `Write` / `Edit` tools (or `Bash`) for files under `DevPlaceSwiftSDK/Sources/...`. `XcodeWrite` will fail with a "directory insertion mode" error for these paths (the file may still be written on disk, but prefer `Write`/`Edit` for clarity).

For files under `DevPlaceIOS/DevPlaceIOS/...` (the app target), use `XcodeWrite` / `XcodeUpdate` so they register with the Xcode project.

## Example skeletons

### Wrapper type (matches `Post.swift`)

```swift
import Foundation

public struct Example: Hashable, Sendable, Identifiable {
    public var id: String { "example:" + data.id }
    public let data: Data
    public let someWrapperField: String
    //public let unknownArray: [???] // empty array in sample - type unknown

    public init(
        data: Data,
        someWrapperField: String,
    ) {
        self.data = data
        self.someWrapperField = someWrapperField
    }
}

public extension Example {
    struct Data: Hashable, Sendable, Identifiable {
        public let id: String
        public let title: String
        public let createdAt: Date

        public init(
            id: String,
            title: String,
            createdAt: Date,
        ) {
            self.id = id
            self.title = title
            self.createdAt = createdAt
        }
    }
}

extension Example {
    struct CodingData: Decodable {
        let example: Data.CodingData
        let some_wrapper_field: String
        //let unknown_array: [???] // empty array in sample
    }
}

extension Example.Data {
    struct CodingData: Decodable {
        let uid: String
        let title: String
        let created_at: Date
    }
}

extension Example.CodingData {
    var decoded: Example {
        .init(
            data: example.decoded,
            someWrapperField: some_wrapper_field,
        )
    }
}

extension Example.Data.CodingData {
    var decoded: Example.Data {
        .init(
            id: uid,
            title: title,
            createdAt: created_at,
        )
    }
}
```

### Flat type (matches `User.swift`)

```swift
import Foundation

public struct Flat: Hashable, Sendable, Identifiable {
    public let id: String
    public let name: String

    public init(
        id: String,
        name: String,
    ) {
        self.id = id
        self.name = name
    }
}

extension Flat {
    struct CodingData: Decodable {
        let uid: String
        let name: String
    }
}

extension Flat.CodingData {
    var decoded: Flat {
        .init(
            id: uid,
            name: name,
        )
    }
}
```

## Out of scope

- Updating mocks under `DevPlaceIOS/Model Mocks/` (mention they are broken, ask first)
- Adding API endpoints in `DevPlaceApi` / `ProdDevPlaceApi` / `MockDevPlaceApi`
- Updating UI / view models
- Writing tests
- Running builds
