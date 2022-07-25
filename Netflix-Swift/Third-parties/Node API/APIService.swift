//
//  APIService.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 18/07/2022.
//

import Foundation

// MARK: - HTTPMethod

enum HTTPMethod: String {
    case get,
         post,
         patch,
         delete
}


// MARK: - APIServiceDelegate

protocol APIServiceDelegate: AnyObject {
    
}



// MARK: - APIService

final class APIService {
    
    // MARK: Properties
    
    static var shared: APIService = .init()
    
    
    var authentication: APIAuthentication = .init()
    
    
    weak var delegate: APIServiceDelegate! = nil
    
    
    // MARK: Initialization
    
    private init() {
        self.delegate = self
    }
}



// MARK: - APIServiceDelegate Implementation

extension APIService: APIServiceDelegate {
    
    func request<T: Decodable>(_ type: T.Type,
                               _ method: HTTPMethod,
                               _ endpoint: Endpoint,
                               _ completion: @escaping (APIResponse<T>) -> Void) {
        
        guard let url = endpoint.url! as URL? else {
            return DispatchQueue.main.async {
                completion(.failure(.custom(message: "Invalid URL")))
            }
        }
        
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = method.rawValue
        
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        URLSession.shared.dataTask(with: request) { data, res, err in
            
            if let err = err {
                return DispatchQueue.main.async {
                    completion(.failure(.custom(message: err.localizedDescription)))
                }
            }
            
            let statusCode = (res as! HTTPURLResponse).statusCode
            print("APIService.statusCode", statusCode)
            
            switch statusCode {
            case 401:
                return DispatchQueue.main.async {
                    completion(.failure(.custom(message: "Sign in in-order to gain access.")))
                }
            case 404:
                return DispatchQueue.main.async {
                    completion(.failure(.custom(message: "Not found")))
                }
            default:
                break
            }
            
            guard
                let response = res as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data
            else {
                return
            }
            
            let decoder: JSONDecoder = .init()
            let decoded: T
            
            do {
                switch type {
                case let type as SectionResponse.Type:
                    decoded = try decoder.decode(type, from: data) as! T
                    
                    return DispatchQueue.main.async {
                        completion(.success(decoded))
                    }
                    
                default:
                    break
                }
            } catch let err {
                return DispatchQueue.main.async {
                    completion(.failure(.custom(message: err.localizedDescription)))
                }
            }
        }.resume()
    }
}
