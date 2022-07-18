//
//  APIService.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 18/07/2022.
//

import Foundation

enum HTTPSegment: String {
    case users
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
    var url: URL { get }
    var request: URLRequest { get }
}

class APIService {
    
    //
    
    static var shared: APIService = .init()
    
    
    var authedUser: UserViewModel! = nil
    
    var authedUserJWTToken: String! = ""
    
    
    weak var delegate: APIServiceDelegate! = nil
    
    private init() {
        self.delegate = self
    }
    
    //
    
    var urlString: String = "https://netflix-swift-api.herokuapp.com/api/v1/users/signin"
    
    var httpMethod: HTTPMethod! = .post
    
    var json: [String: Any] = ["email": "admin@gmail.com", "password": "adminpassword"]
    
    var httpBody: Data! {
        do {
            return try JSONSerialization.data(withJSONObject: json, options: [])
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    
    var url: URL {
        return .init(string: urlString)!
    }
    
    var request: URLRequest {
        var request: URLRequest = .init(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        return request
    }
    
    func request(_ segment: HTTPSegment, _ method: HTTPMethod) {
        URLSession.shared.dataTask(with: request) { data, res, err in
            if let err = err {
                print("RequestError", err)
                
                return
            }
            
            print((res as! HTTPURLResponse).statusCode)
            
            guard
                let response = res as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data
            else {
                return
            }
            
            let decoder: JSONDecoder = .init()
            
            do {
                let authSignInResponse = try decoder.decode(SignInResponse.self, from: data)
                print(authSignInResponse)
            } catch let err {
                print(err)
            }
        }.resume()
    }
}

extension APIService: APIServiceDelegate {
    
}
