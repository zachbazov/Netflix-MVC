//
//  APIAuthentication.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 20/07/2022.
//

import Foundation

// MARK: - APIAuthenticationDelegate

protocol APIAuthenticationDelegate: AnyObject {
    func signUp<T: Decodable>(_ type: T.Type,
                              _ name: String?,
                              _ email: String?,
                              _ password: String?,
                              _ passwordConfirm: String?,
                              _ completion: @escaping (APIResponse<T>) -> Void)
    func signIn<T: Decodable>(_ type: T.Type,
                              _ email: String?,
                              _ password: String?,
                              _ completion: @escaping (APIResponse<T>) -> Void)
}


// MARK: - Authentication

final class APIAuthentication {
    
    // MARK: Properties
    
    var credentials: APICredentials! = .init(jwt: nil, user: nil)
    
    weak var delegate: APIAuthenticationDelegate! = nil
    
    
    // MARK: Initialization
    
    init() {
        self.delegate = self
    }
}


// MARK: - AuthenticationDelegate Implementation

extension APIAuthentication: APIAuthenticationDelegate {
    
    func signUp<T: Decodable>(_ type: T.Type, _ name: String?, _ email: String?, _ password: String?, _ passwordConfirm: String?, _ completion: @escaping (APIResponse<T>) -> Void) {
        let url: URL = .init(string: "https://netflix-swift-api.herokuapp.com/api/v1/users/signup")!
        let json: [String: Any]
        var httpBody: Data = .init()
        var request: URLRequest = .init(url: url)
        json = [
            "name": name!,
            "email": email!,
            "password": password!,
            "passwordConfirm": passwordConfirm!
        ]
        do {
            httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        } catch let err {
            print(err)
        }
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        URLSession.shared.dataTask(with: request) { data, res, err in
            if let err = err {
                return DispatchQueue.main.async {
                    completion(.failure(.custom(message: err.localizedDescription)))
                }
            }
            let statusCode = (res as! HTTPURLResponse).statusCode
            print("APIAuthentication.statusCode", statusCode)
            switch statusCode {
            case 400:
                return DispatchQueue.main.async {
                    completion(.failure(.custom(message: "A valid credentials required in-order to gain access.")))
                }
            case 401:
                return DispatchQueue.main.async {
                    completion(.failure(.custom(message: "Invalid credentials")))
                }
            default:
                print(33, statusCode)
            }
            guard
                let response = res as? HTTPURLResponse,
                response.statusCode == 201,
                let data = data
            else { return }
            let decoder = JSONDecoder()
            let decoded: T
            do {
                switch type {
                case let type as AuthResponse.Type:
                    decoded = try decoder.decode(type, from: data) as! T
                    DispatchQueue.main.async {
                        completion(.success(decoded))
                    }
                default: break
                }
            } catch let err {
                return DispatchQueue.main.async {
                    completion(.failure(.custom(message: err.localizedDescription)))
                }
            }
        }.resume()
    }
    
    func signIn<T: Decodable>(_ type: T.Type, _ email: String?, _ password: String?, _ completion: @escaping (APIResponse<T>) -> Void) {
        let url: URL = .init(string: "https://netflix-swift-api.herokuapp.com/api/v1/users/signin")!
        let json: [String: Any]
        var httpBody: Data = .init()
        var request: URLRequest = .init(url: url)
        json = [
            "email": email!,
            "password": password!
        ]
        do {
            httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        } catch let err {
            print(err)
        }
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        URLSession.shared.dataTask(with: request) { data, res, err in
            if let err = err {
                return DispatchQueue.main.async {
                    completion(.failure(.custom(message: err.localizedDescription)))
                }
            }
            let statusCode = (res as! HTTPURLResponse).statusCode
            print("APIAuthentication.statusCode", statusCode)
            switch statusCode {
            case 400:
                return DispatchQueue.main.async {
                    completion(.failure(.custom(message: "A valid credentials required in-order to gain access.")))
                }
            case 401:
                return DispatchQueue.main.async {
                    completion(.failure(.custom(message: "Invalid credentials")))
                }
            default: break
            }
            guard
                let response = res as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data
            else { return }
            let decoder = JSONDecoder()
            let decoded: T
            do {
                switch type {
                case let type as AuthResponse.Type:
                    decoded = try decoder.decode(type, from: data) as! T
                    DispatchQueue.main.async {
                        completion(.success(decoded))
                    }
                default: break
                }
            } catch let err {
                return DispatchQueue.main.async {
                    completion(.failure(.custom(message: err.localizedDescription)))
                }
            }
        }.resume()
    }
}
