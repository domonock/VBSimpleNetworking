import Foundation
public class VBSimpleNetworking {
    public static func getDataFrom<T: Decodable>(url: String, dataType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        VBServerManager.getDataFrom(url: url, dataType: dataType, completion: completion)
    }
    
    public static func getImages(imagesURLs: [String], completion: @escaping (Result<[Data], Error>) -> Void) {
        VBServerManager.getImages(images: imagesURLs, completion: completion)
    }
}
