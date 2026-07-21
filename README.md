# Template

Template is a lightweight Swift library for rendering string templates. Create a template from a string or file, assign values, and read its rendered output.

## Requirements

- Swift 5.7+

## Installation

Add Template to the dependencies in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/tomieq/Template.swift.git", from: "1.6.0")
]
```

Then add the product to the target that uses it:

```swift
.executableTarget(
    name: "YourApp",
    dependencies: [
        .product(name: "Template", package: "Template.swift")
    ]
)
```

Import the module where needed:

```swift
import Template
```

## Quick start

```swift
let template = Template(raw: "Hello, {name}! You have {count} messages.")
template.assign("name", "Thomas")
template["count"] = 3

print(template.output) // Hello, Thomas! You have 3 messages.
```

`Template` conforms to `CustomStringConvertible`, so using it as a string renders its output:

```swift
print(template)
```

## Creating templates

Create a template from a string with `init(raw:interpolation:)`. The interpolation style defaults to `.default`.

```swift
let template = Template(raw: "Welcome, {name}!")
```

### Interpolation styles

Choose one `TemplateInterpolation` style for each template:

| Style | Placeholder syntax | Example |
| --- | --- | --- |
| `.default` | `{name}` | `Template(raw: "{name}")` |
| `.mustache` | `{{name}}` | `Template(raw: "{{name}}", interpolation: .mustache)` |
| `.dollar` | `$name` | `Template(raw: "$name", interpolation: .dollar)` |
| `.dollarWithBraces` | `${name}` | `Template(raw: "${name}", interpolation: .dollarWithBraces)` |

All assignment APIs work with every style:

```swift
let template = Template(raw: "Hello, {{name}}!", interpolation: .mustache)
template["name"] = "Thomas"
print(template.output) // Hello, Thomas!
```

Placeholder and repeated-section names should contain only letters, numbers, hyphens, and underscores.

## Assigning values

Template values conform to `CustomStringConvertible`; their `description` is inserted into the output. `TemplateVariables` is the dictionary type used for batch assignment:

```swift
let variables: TemplateVariables = ["name": "Thomas", "count": 3]
let template = Template(raw: "{name}: {count}")
template.assign(variables)
```

### One value

Use `assign(_:_:)` or the subscript setter:

```swift
let template = Template(raw: "{name}")
template.assign("name", "Thomas")
// Equivalent:
template["name"] = "Thomas"
```

The subscript is assignment-only; reading `template["name"]` returns `nil`.

### A dictionary

Use `assign(_:)` to assign multiple values:

```swift
let template = Template(raw: "{number} {name}")
template.assign(["number": 45, "name": "Tom"])
print(template.output) // 45 Tom
```

### A model

Use `assign(_:)` with a class or struct to assign its reflected stored properties:

```swift
struct ViewModel {
    let name: String
    let number: Int
}

let template = Template(raw: "{number} {name}")
template.assign(ViewModel(name: "Tom", number: 45))
print(template.output) // 45 Tom
```

Only reflected properties whose values conform to `CustomStringConvertible` are assigned. Assignment methods return the same template, so they can be chained:

```swift
let output = Template(raw: "{greeting}, {name}!")
    .assign("greeting", "Hello")
    .assign("name", "Tom")
    .output
```

## Repeated sections

Define a repeated section with `[START name]` and `[END name]`. Assign variables to it with `assign(_:inNest:)`; every call appends one rendered copy of the section.

```swift
let template = Template(raw: """
<ul>
[START item]<li>{name}</li>
[END item]</ul>
""")

template.assign(["name": "One"], inNest: "item")
template.assign(["name": "Two"], inNest: "item")

print(template.output)
// <ul>
// <li>One</li>
// <li>Two</li>
// </ul>
```

Models can also be assigned to a section:

```swift
template.assign(ViewModel(name: "Three", number: 3), inNest: "item")
```

If a section is never assigned, it does not appear in the output. Section names use the same character restrictions as placeholder names.

## Rendering and resetting

Read `output` to render the template. Unassigned placeholders are removed:

```swift
let template = Template(raw: "Hello, {name}!{optional}")
template["name"] = "Tom"
print(template.output) // Hello, Tom!
```

Rendering removes unassigned placeholders from the template's current state. Call `reset()` to restore the original raw template and clear all rendered repeated sections before reusing it:

```swift
template.reset()
template["name"] = "Ada"
print(template.output) // Hello, Ada!
```

## Loading files and resources

`Resource` resolves relative paths under a `Resources` directory in a working directory. Its default working directory is `FileManager.default.currentDirectoryPath`.

```swift
let resource = Resource()
let path = resource.absolutePath(for: "response.tpl.html")
// <current working directory>/Resources/response.tpl.html

let content = resource.content(for: "response.tpl.html")
```

`content(for:)` returns `nil` and prints a diagnostic when the file cannot be read. Supply `workingDir` to use a different base directory:

```swift
let resource = Resource(workingDir: "/web/app")
```

Create a template directly from a file:

```swift
// Resolves <working directory>/Resources/response.tpl.html
let relativeTemplate = Template.load(relativePath: "response.tpl.html")

let absoluteTemplate = Template.load(absolutePath: "/web/app/Resources/response.tpl.html")
```

`Template.load` prints a diagnostic and returns an empty template if the file cannot be read. File-loading APIs use the default `{name}` interpolation style; for another style, load the string with `Resource` and pass it to `Template(raw:interpolation:)`.

## File caching

Use `Template.cached` to retain file contents in the process-wide in-memory cache. The first call reads the file; later calls for the same absolute path use the cached content.

```swift
let relativeTemplate = Template.cached(relativePath: "response.tpl.html")
let absoluteTemplate = Template.cached(absolutePath: "/web/app/Resources/response.tpl.html")
```

If a cached file cannot be read, these methods return an empty template. The cache is process-local and has no public invalidation API; use `Template.load` when fresh file contents are required.
