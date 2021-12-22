//
//  File.swift
//  
//
//  Created by Владимир Бабич on 22.12.2021.
//
import Foundation

class VBServerManager {
    private static let group = DispatchGroup()
    public static var lastResponseObject: Any?
    public static var isDebugMode = false
    
    private static func getSomeData<T: Decodable>(url: String, dataType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: url) else {
            return
        }
        let urlSession = URLSession(configuration: .default).dataTask(with: url) { data, response, error in
            let decoder = JSONDecoder()
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                if let jsonPetitions:T = try? decoder.decode(T.self, from: data) {
                    completion(.success(jsonPetitions))
                } else {
                    let error = NSError()
                    completion(.failure(error))
                }
            }
        }
        urlSession.resume()
        return
    }
    
    static func getDataFrom<T: Decodable>(url: String, dataType: T.Type) -> T {
        group.enter()
        VBServerManager.getSomeData(url: url, dataType: dataType ) { result in
            switch result {
            case .success(let resultObj):
                self.lastResponseObject = resultObj
                self.group.leave()
            case .failure(let error):
                if isDebugMode {
                    print(error)
                }
                self.group.leave()
            }
        }
        self.group.wait()
        group.notify(queue: .global()) {
            if isDebugMode {
                if let obj = lastResponseObject {
                    print("DataLoaded: \(obj)")
                }
            }
        }
        return lastResponseObject as! T
    }
}
