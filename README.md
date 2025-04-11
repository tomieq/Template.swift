# Template

Template is a swift library for loading String templates from files. It allows assinging variables to the template's placeholders.

## Template's variables
Sample temaplate:
```
This is sample template with variable {name} and number {number}
```
Swift code:
```swift
let template = Template.load(relativePath: "response.tpl.html")
template.assign("name", Thomas")
// or even simplier
template["number"] = 502
let output = template.output
```
You can also pass data with `class` or `struct` instance:
```swift
struct ViewModel {
    let name: String
    let number: Int
}
let template = Template(raw: "{number} {name}")
let model = ViewModel(name: "Tom", number: 45)
template.assign(model)
```
You can pass multiple variables from dictionary as well:
```swift
let template = Template(raw: "{number} {name}")
template.assign(["number": 875, "name": "Tom"])
```
## Template's interation variables
Sample temaplate:
```
header
[START item]
This will be added multiple times with variable {number}
[END item]
footer
```
Swift code:
```swift
let template = Template(from: "response.tpl.html")
for i in 1...3 {
    template.assign(["number": i], inNest: "item")
}
template.assign(["name": "Thomas"])
let output = template.output
```
## Support for multiple interpolation types
In template you can create placeholders with different formats.
#### Default `{value}`
```swift
let template = Template(raw: "{number}")
template["number"] = 406
```
#### Mustache `{{value}}`
```swift
let template = Template(raw: "{{number}}", interpolation: .mustache)
template["number"] = 406
```
#### Dollar `$value`
```swift
let template = Template(raw: "$number", interpolation: .dollar)
template["number"] = 406
```
#### Dollar with braces `${value}`
```swift
let template = Template(raw: "${number}", interpolation: .dollarWithBraces)
template["number"] = 406
```
### Resource

`Resource` helps load content of files that are located in `/Resources` folder relative to directory from which binary is launched
```swift
let res = Resource()

let template = Template(raw: res.content(for: "response.tpl.html"))
// or
let template = Template.load(absolutePath: "/web/app/Resources/response.tpl.html")
// or relative to the working dir that app was started, it searches files in the `Resources` folder:
let template = Template.load(relativePath: "response.tpl.html")
```
In case resource will not find the file it returns nil. Template will be initialized with empty String.


Typical cooperation with Swifter:
```swift
server.notFoundHandler = { request, _ in
    let filePath = Resource().absolutePath(for: request.path)
    try HttpFileResponse.with(absolutePath: filePath, clientCache: .days(7))
    return .notFound()
}
```
### Cache

Heavy load can cause IO problems, so it is recommended to keep template's file content cached instead of reading it from hard disc. The library has in-build caching system that loads the resources only once and then keep them in the memory.
```swift
let template = Template.cahed(relativePath: "response.tpl.html")
// or
let template = Template.cahed(absolutePath: "/web/app/Resources/response.tpl.html")
```

### Swift Package Manager
```
    dependencies: [
        .package(url: "https://github.com/tomieq/Template.swift.git", from: "1.6.0")
    ],
    
    ...
    
    .executableTarget(
        name: "YourApp",
        dependencies: [
            .product(name: "Template", package: "Template.swift")
        ]),
```
