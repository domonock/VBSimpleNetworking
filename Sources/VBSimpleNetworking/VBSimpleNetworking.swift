import Foundation
public class VBSimpleNetworking {
    public static func getDataFrom<T: Decodable>(url: String, dataType: T.Type) -> T {
        return VBServerManager.getDataFrom(url: url, dataType: dataType)
    }
    
    public static func getImages(imagesURLs: [String], completion: @escaping (Result<[Data], Error>) -> Void) {
        VBServerManager.getImages(images: imagesURLs, completion: completion)
    }
}
