# Template

Template is a swift library for loading String templates from files. It allows assinging variables to the template's placeholders.

## Template's variables
Sample temaplate:
```
This is sample template with variable {name}
```
Swift code:
```swift
let template = Template(from: "response.tpl.html")
template.assign(["name": "Thomas"])
let output = template.output
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
### Resource

`Resource` helps load content of files that are located in `/Resources` folder relative to directory from which binary is launched
```swift
let res = Resource()

let template = Template(raw: res.content(for: "response.tpl.html"))
// or
let template = Template(from: "response.tpl.html")
```
In case resource will not find the file it returns nil. Template will be initialized with empty String.


Typical cooperation with Swifter:
```swift
        server.notFoundHandler = { request, responseHeaders in
            request.disableKeepAlive = true
            let filePath = Resource().absolutePath(for: request.path)
            if FileManager.default.fileExists(atPath: filePath) {
                guard let file = try? filePath.openForReading() else {
                    print("Could not open `\(filePath)`")
                    return .notFound()
                }
                let mimeType = filePath.mimeType()
                responseHeaders.addHeader("Content-Type", mimeType)

                if let attr = try? FileManager.default.attributesOfItem(atPath: filePath),
                   let fileSize = attr[FileAttributeKey.size] as? UInt64 {
                    responseHeaders.addHeader("Content-Length", String(fileSize))
                }

                return .raw(200, "OK", { writer in
                    try writer.write(file)
                    file.close()
                })
            }
            print("File `\(filePath)` doesn't exist")
            return .notFound()
        }
```
### Cache

Heavy load can cause IO problems, so it is recommended to keep template's file content cached instead of reading it from hard disc. The library has in-build caching system that loads the resources only once and then keep them in the memory.
```swift
let template = Template.cahed(from: "response.tpl.html")
```

### Swift Package Manager
```
    
    dependencies: [
        .package(url: "https://github.com/tomieq/Template.swift.git", .branch("master"))
    ],
    
    ...
    
    .executableTarget(
        name: "YourApp",
        dependencies: [
                       .product(name: "Template", package: "Template.swift")
                       ]),
```
