public class VBSimpleNetworking {
    
    public static func getDataFrom<T: Decodable>(url: String, dataType: T.Type) -> T {
        return VBServerManager.getDataFrom(url: url, dataType: dataType)
    }
    
}
