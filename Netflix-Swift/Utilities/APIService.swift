//
//  APIService.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 18/07/2022.
//

import Foundation


enum RequestError: CustomStringConvertible {
    
    case custom(message:String)
    case noInternetConnection
    case generic
    case failedWithStatusCode(statusCode:Int)
    
    var description : String {
        switch self {
        case .noInternetConnection:
            return "Please check your internet connectivity."
        case .custom(let message):
            return message
        case .generic:
            return "There is a technical issue. Please contact us if the issue persists."
        case .failedWithStatusCode(let code):
            return "Failed with status code \(code)"
        }
    }
}

enum APIResponse<T> {
    case success(T)
    case failure(RequestError)
}


enum HTTPSegment: String {
    case users = "https://netflix-swift-api.herokuapp.com/api/v1/users"
    case auth = "https://netflix-swift-api.herokuapp.com/api/v1/users/signin"
}

enum HTTPMethod: String {
    case get,
         post,
         patch,
         delete
}

protocol APIAuthenticationDelegate: AnyObject {
    
}

protocol APIServiceDelegate: AnyObject {
    //    var url: URL { get }
    //    var request: URLRequest { get }
}


protocol AuthenticationDelegate: AnyObject {
    func signIn(email: String, password: String)
}

class Authentication {
    
    //
    
    var authedUser: UserViewModel! = nil
    
    var authedUserJWTToken: String! = ""
    
    
    weak var delegate: AuthenticationDelegate! = nil
    
    
    //
    
    init() {
        self.delegate = self
    }
}

extension Authentication: AuthenticationDelegate {
    
    func signIn(email: String, password: String) {
        //        APIService.shared.request(.users, .post)
    }
}



class APIService {
    
    //
    
    static var shared: APIService = .init()
    
    
    var authentication: Authentication = .init()
    
    
    weak var delegate: APIServiceDelegate! = nil
    
    //
    
    enum URLProtocol: String {
        case http = "http://"
        case https = "https://"
    }
    
    enum URLSubdomain: String {
        case local
        case heroku = "netflix-swift-api.herokuapp.com/"
    }
    
    enum URLPath: String {
        case sections = "api/v1/sections"
        case users = "api/v1/users"
        case signIn = "api/v1/users/signin"
        
        var urlValue: URL {
            return URL(string: self.rawValue)!
        }
    }
    
    var urlProtocol: URLProtocol = .https
    
    var urlSubdomain: URLSubdomain = .heroku
    
    var urlPath: URLPath = .sections
    
    
    enum URLLink {
        case section
        case users
        case signIn
        
        var urlValue: URL {
            switch self {
            case .section:
                APIService.shared.urlPath = .sections
            case .users:
                APIService.shared.urlPath = .users
            case .signIn:
                APIService.shared.urlPath = .signIn
            }
            
            return URL(string: "\(APIService.shared.urlProtocol.rawValue)\(APIService.shared.urlSubdomain.rawValue)\(APIService.shared.urlPath.rawValue)")!
        }
    }
    
    
    //
    
    private init() {
        self.delegate = self
    }
    
    
    //
    
    func request<T: Decodable>(_ type: T.Type, _ link: URLLink, _ completion: @escaping (APIResponse<T>) -> Void) {
        
        let url: URL = link.urlValue
        
        let json: [String: Any]
        var httpBody: Data = .init()
        
        var request: URLRequest = .init(url: url)
        
        switch link {
        case .section:
            request.httpMethod = HTTPMethod.get.rawValue
        case .users:
            break
        case .signIn:
            do {
                json = [
                    "email": "admin@gmail.com",
                    "password": "adminpassword"
                ]
                httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
            } catch let err {
                print(err)
            }
            
            request.httpMethod = HTTPMethod.post.rawValue
            request.httpBody = httpBody
        }
        
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        URLSession.shared.dataTask(with: request) { data, res, err in
            if let err = err {
                return completion(.failure(.custom(message: err.localizedDescription)))
            }
            
            let statusCode = (res as! HTTPURLResponse).statusCode
            print("APIService.statusCode", statusCode)
            
            switch statusCode {
            case 401:
                completion(.failure(.custom(message: "Invalid credentials")))
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
                case let type as SignInResponse.Type:
                    decoded = try decoder.decode(type, from: data) as! T
                    
                    completion(.success(decoded))
                    
                case let type as SectionResponse.Type:
                    decoded = try decoder.decode(type, from: data) as! T
                    
                    completion(.success(decoded))
                    
                default:
                    break
                }
            } catch let err {
                completion(.failure(.custom(message: err.localizedDescription)))
            }
        }.resume()
    }
}

extension APIService: APIServiceDelegate {
    
}
