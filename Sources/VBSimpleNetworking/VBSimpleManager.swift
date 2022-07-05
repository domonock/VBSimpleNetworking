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
    private static let semaphore = DispatchSemaphore(value: 2)
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
    
    static func getImages(images: [String], completion: @escaping (Result<[Data], Error>) -> Void) {
        var downloadedImages = [Data]()
        for image in images {
            semaphore.wait()
            self.group.enter()
            self.downloadImage(fromUrl: image) { response in
                if let imageData = response.imageData {
                    downloadedImages.append(imageData)
                    self.group.leave()
                    self.semaphore.signal()
                } else {
                    self.group.leave()
                    self.semaphore.signal()
                    let error = NSError()
                    completion(.failure(error))
                }
            }
        }
        self.group.wait()
        group.notify(queue: .global()) {
            print(downloadedImages.count)
            completion(.success(downloadedImages))
        }
    }
    
    private static func downloadImage(fromUrl URLString: String, with completion: @escaping (_ response: (status: Bool, imageData: Data? ) ) -> Void) {
        guard let url = URL(string: URLString) else {
            completion((status: false, imageData: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion((status: false, imageData: nil))
                return
            }
            
            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200,
                  let data = data else {
                completion((status: false, imageData: nil))
                return
            }
            
            guard let data = data else {return}
            completion((status: true, imageData: data))
        }.resume()
    }
}
