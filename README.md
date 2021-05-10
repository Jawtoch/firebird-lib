# firebird-lib

Firebird Swift Wrapper.
It require Clibfbclient, please see [installation procedure](https://github.com/Jawtoch/Clibfbclient/blob/main/README.md#clibfbclient).

## Usage

### Connection

To connect to database server, provide a configuration. Currently, the connection timeout is set to 10 seconds, and cannot be changed.

```swift
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

```swift
try connection.query("SELECT * FROM employee") { row in
	// Process row here
}
```

Alternatively, you can retrieve rows without callback:

```swift
let rows = try connection.query("SELECT * FROM employee")
```

### Binding data 

You can bind data to your queries by passing an array of FirebirdData conforming types. Data will be bonded to the query, by replacing the placeholder `?` to the provided value, in the given order.

```swift
var value: Int32 = 42
let data = withUnsafeBytes(of: &value) { Data($0) }
let firebirdData = FirebirdData(type: .long, value: data) 
let rows = try connection.query("SELECT * FROM employee WHERE emp_no = ?", [firebirdData])
```
