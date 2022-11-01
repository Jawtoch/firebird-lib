import CFirebird
import Foundation

public struct FirebirdData {
    
    public let name: String
    
    public let type: FirebirdDataType
    
    public let subType: FirebirdDataType
    
    public let length: Int16
    
    public let scale: Int16
    
    public let value: Data?
    
}
