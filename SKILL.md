---
name: template-swift-usage
description: "Use when writing Swift code in a project that depends on (or should add) the Template package (https://github.com/tomieq/Template.swift) to render string templates: HTML, text, or any file with {name}, {{name}}, $name or ${name} placeholders, repeated sections ([START x]...[END x]), loading templates from a Resources directory, and caching. Covers installation via Swift Package Manager and the full public API."
---

# Using Template in a Swift project

Template is a lightweight Swift (5.7+) string-templating library. Create a template from a string or file, assign values, read `output`. Prefer it over hand-written `replacingOccurrences` chains or string concatenation when producing HTML, emails, text, or other documents from a skeleton.

## Installation (Swift Package Manager)

1. Add the dependency in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tomieq/Template.swift.git", from: "1.6.0")
]
```

2. Add the product to the target that uses it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Template", package: "Template.swift")
    ]
)
```

3. Import the module:

```swift
import Template
```

In an Xcode project: File > Add Package Dependencies, enter the URL above, and add the `Template` library to the target.

## Quick start

```swift
let template = Template(raw: "Hello, {name}! You have {count} messages.")
template.assign("name", "Thomas")
template["count"] = 3
print(template.output) // Hello, Thomas! You have 3 messages.
```

`Template` conforms to `CustomStringConvertible`, so `"\(template)"` and `print(template)` render the output too.

## Public API summary

| API | Purpose |
| --- | --- |
| `Template(raw:interpolation:)` | Create a template from a string; interpolation defaults to `.default` |
| `assign(_ key:, _ value:)` / `template[key] = value` | Assign one value |
| `assign(_ variables: TemplateVariables)` | Assign a dictionary `[String: CustomStringConvertible]` |
| `assign(_ model: Any)` | Assign stored properties of a struct/class (reflection) |
| `assign(_ variables:, inNest:)` / `assign(_ model:, inNest:)` | Append one copy of a repeated section |
| `output` / `description` | Render the result |
| `reset()` | Restore the original raw template and clear section copies |
| `Template.load(relativePath:)` / `load(absolutePath:)` | Read a template file on every call |
| `Template.cached(relativePath:)` / `cached(absolutePath:)` | Read a template file once, cache content in memory |
| `Resource(workingDir:)` | `absolutePath(for:)` and `content(for:)` for files under `<workingDir>/Resources/` |
| `TemplateInterpolation` | `.default`, `.mustache`, `.dollar`, `.dollarWithBraces` |
| `TemplateVariables` | Typealias for `[String: CustomStringConvertible]` |

All `assign` methods and `reset()` return the template (`@discardableResult`), so calls can be chained:

```swift
let html = Template(raw: "{greeting}, {name}!")
    .assign("greeting", "Hello")
    .assign("name", "Tom")
    .output
```

## Interpolation styles

Pick one style per template.

| Style | Placeholder | Construction |
| --- | --- | --- |
| `.default` | `{name}` | `Template(raw: "{name}")` |
| `.mustache` | `{{name}}` | `Template(raw: "{{name}}", interpolation: .mustache)` |
| `.dollar` | `$name` | `Template(raw: "$name", interpolation: .dollar)` |
| `.dollarWithBraces` | `${name}` | `Template(raw: "${name}", interpolation: .dollarWithBraces)` |

Use `.mustache` or `.dollar*` when the document itself contains single braces (CSS, JavaScript, JSON). Placeholder and section names may contain only letters, digits, hyphens, and underscores. Assignment calls look the same for every style; pass the bare name (`"name"`), never the delimiters.

## Assigning values

Values must conform to `CustomStringConvertible`; their `description` is inserted. Numbers, strings, `Bool`, `Date`, enums with descriptions, etc. work directly.

```swift
// Dictionary
let template = Template(raw: "{number} {name}")
template.assign(["number": 45, "name": "Tom"])

// Model (stored properties whose values are CustomStringConvertible)
struct ViewModel { let name: String; let number: Int }
template.assign(ViewModel(name: "Tom", number: 45))
```

Notes:

- The subscript is set-only; `template["x"]` always returns `nil`.
- Assigning `nil` through the subscript is ignored.
- Model assignment uses `Mirror`; properties not conforming to `CustomStringConvertible` (e.g. nested non-printable structs) are skipped. Optional properties are unwrapped: the value is inserted when present and `""` when `nil`. (Dictionary values of type `TemplateVariables` cannot be optional; unwrap them yourself.)
- Values are inserted as-is. Template does not escape HTML; escape user input yourself before assigning it into HTML.

## Repeated sections

Wrap a block in `[START name]` and `[END name]`. Each `assign(_:inNest:)` call appends one rendered copy of the block.

```swift
let template = Template(raw: """
<ul>
[START item]<li>{name}</li>
[END item]</ul>
""")

for name in ["One", "Two"] {
    template.assign(["name": name], inNest: "item")
}
print(template.output)
// <ul>
// <li>One</li>
// <li>Two</li>
// </ul>
```

- Models work too: `template.assign(ViewModel(...), inNest: "item")`.
- A section that is never assigned renders as nothing (useful for conditional blocks: assign once to show, never to hide).
- Variables inside a section are only substituted via `inNest:` calls; top-level `assign` does not affect them.
- Section markers work with every interpolation style (`[START name]` / `[END name]` are the same for all).

## Rendering and reuse

Reading `output` removes any still-unassigned placeholders from the template's current state. To reuse the same instance with new values, call `reset()` first:

```swift
template.reset()
template["name"] = "Ada"
print(template.output)
```

Alternatively create a new `Template` per render (cheap), or use `Template.cached(...)` which builds a fresh `Template` from cached text each call.

## Loading templates from files

`Resource` resolves paths as `<workingDir>/Resources/<relativePath>`. The default `workingDir` is `FileManager.default.currentDirectoryPath`.

```swift
let template = Template.load(relativePath: "page.tpl.html")           // <cwd>/Resources/page.tpl.html
let other = Template.load(absolutePath: "/web/app/Resources/page.tpl.html")

let resource = Resource(workingDir: "/web/app")
let path = resource.absolutePath(for: "page.tpl.html")
let text: String? = resource.content(for: "page.tpl.html")
```

- On read failure, `load`/`cached` print a diagnostic and return an empty template (no throw).
- `load` and `cached` always use `.default` (`{name}`) interpolation. For another style, read the text and construct manually:

```swift
if let raw = Resource().content(for: "mail.tpl.txt") {
    let template = Template(raw: raw, interpolation: .mustache)
}
```

- When using SwiftPM, the `Resources` directory is resolved against the process working directory, not the bundle. Make sure the process is started from the directory that contains `Resources/` (or pass `workingDir`).

## Caching

`Template.cached(relativePath:)` and `Template.cached(absolutePath:)` keep file contents in a process-wide in-memory cache keyed by absolute path. The first call reads the file, later calls reuse the text. There is no public invalidation API, so edits to the file are not picked up until the process restarts; use `Template.load` when fresh content is required (e.g. during development).

## Guidance for agents

- Prefer `Template.cached` in long-running servers for static template files; prefer `Template.load` during development.
- Create a new `Template` for each render unless you explicitly call `reset()`.
- Do not use `{...}` placeholders in text that contains literal braces; switch to `.mustache`, `.dollar`, or `.dollarWithBraces` instead.
- Do not read back values via the subscript; keep values in your own model.
- Escape untrusted input before assigning it into HTML or other markup.
