# firebird-lib

Firebird Swift Wrapper.
It require linking the Firebird.framework under macOS, or the Firebird library `fbclient` under Linux. On macOS, `ld` defaults framework search paths are:

```
- /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks
- /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.1.sdk/System/Library/Frameworks/
```

Since the Firebird framework is required, I provide a xcframework in the `CFirebird` package, which bundle the `FirebirdCS-2.5.9-27139-x86_64` framework.

Under Linux, simply install the firebird libraries at the default paths:

```
- Shared libraries: /usr/lib/x86_64-linux-gnu/ 
- Headers: /usr/include/
```

Alternatively, you can set the ld search path with the `LD_LIBRARY_PATH` env variable.
The linux firebird installer install the libraries at `/opt/firebird/lib` by default

```
LD_LIBRARY_PATH=/opt/firebird/lib/
export LD_LIBRARY_PATH
```

If you have a better idea to make this package working under macOS, tell me!

If you don't want to `CFirebird`, you can link against the Firebird framework with giving the framework search path to `ld`.

```
swift build -Xlinker -F/Library/Frameworks
```

As Swift Package doesn't allow unsafe linker flags for remote package, I cannot distribute it with this option.
## Usage

### Connection

To connect to database server, provide a configuration. Currently, the connection timeout is set to 10 seconds, and cannot be changed.

```
let configuration = FirebirdConnectionConfiguration(
	hostname: "<hostname>",
	port: "<port>",
	username: "<username>",
	password: "<password>",
	database: "<database-name>"
)

let connection = try FirebirdConnection.connect(configuration)
defer {
	try connection.close()
}
```

### Query

Firebird provide two types of queries: simple, and default. Simple queries are for queries without output, like "UPDATE, CREATE", and default are for queries with output "SELECT".

```
try connection.query("SELECT * FROM employee") { row in
	// Process row here
}
```

Alternatively, you can retrieve rows without callback:

```
let rows = try connection.query("SELECT * FROM employee")
```

### Binding data 

You can bind data to your queries by passing an array of FirebirdData conforming types. Data will be bonded to the query, by replacing the placeholder `?` to the provided value, in the given order.

```
var value: Int32 = 42
let data = withUnsafeBytes(of: &value) { Data($0) }
let firebirdData = FirebirdData(type: .long, value: data) 
let rows = try connection.query("SELECT * FROM employee WHERE emp_no = ?", [firebirdData])
```
