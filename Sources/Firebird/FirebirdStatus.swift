import CFirebird

public typealias FirebirdStatus = [ISC_STATUS]

private func makeFirebirdStatus() -> FirebirdStatus {
    FirebirdStatus(repeating: .zero, count: Int(ISC_STATUS_LENGTH))
}

internal func statusContainsError(_ status: FirebirdStatus) -> Bool {
    status[0] == 1 && status[1] > 0
}

@discardableResult
public func withStatus<T>(_ closure: (inout FirebirdStatus) throws -> T) rethrows -> (status: FirebirdStatus, result: T) {
    var status = makeFirebirdStatus()
    let result = try closure(&status)
    return (status, result)
}

@discardableResult
public func withStatusThrowing<T>(_ closure: (inout FirebirdStatus) throws -> T) throws -> T {
    let (status, result) = try withStatus(closure)
    if status[0] == 1 && status[1] > 0 {
        throw FirebirdNativeError(status: status)
    }
    
    return result
}
