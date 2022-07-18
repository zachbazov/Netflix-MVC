//
//  URLService.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 17/04/2022.
//

import UIKit

// MARK: - URLService

final class URLService {
    
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
        
        var urlValue: URL {
            return URL(string: self.rawValue)!
        }
    }
    
    var urlProtocol: URLProtocol = .https
    
    var urlSubdomain: URLSubdomain = .heroku
    
    var urlPath: URLPath = .sections
    
    
    enum URLLink {
        case section
        
        var urlValue: URL {
            
            return URL(string: "\(URLService.shared.urlProtocol.rawValue)\(URLService.shared.urlSubdomain.rawValue)\(URLService.shared.urlPath.rawValue)")!
        }
    }
    
    
    // MARK: Properties
    
    static let shared: URLService = .init()
    
    
    let session: URLSession = .init(configuration: .default)
    
    private(set) var cache: NSCache<NSString, UIImage> = .init()
    
    private let queue: DispatchQueue = .init(label: "URLService", qos: .background)
    
    var configuration: URLSessionConfiguration {
        let configuration: URLSessionConfiguration = .background(withIdentifier: "URLService")
        configuration.timeoutIntervalForRequest = 10
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        return configuration
    }
    
    var task: URLSessionDataTask! = nil
    
    
    // MARK: Initialization
    
    private init() {}
    
    
    // MARK: Methods
    
    func downloadImage(_ url: URL,
                       for identifier: NSString,
                       completion: ((UIImage) -> Void)? = nil) {
        
        if let image = cache.object(forKey: identifier) {
            
            DispatchQueue.main.async {
                completion?(image) ?? {}()
            }
        } else {
            
            task = session.dataTask(with: url) { [weak self] data, response, error in
                guard
                    error == nil,
                    let self = self,
                    let httpURLResponse = response as? HTTPURLResponse,
                    let mimeType = response?.mimeType,
                    let data = data,
                    let image = UIImage(data: data),
                    httpURLResponse.statusCode == 200,
                    mimeType.hasPrefix("image")
                else {
                    return
                }
                
                self.set(image, forKey: identifier)
                
                DispatchQueue.main.async {
                    completion?(image) ?? {}()
                }
            }
            
            task.resume()
        }
    }
    
    func cancelTask(for identifier: NSString) {
        guard task != nil else {
            return
        }

        task.cancel()
        task = nil
    }
    
    func object(for identifier: NSString) -> UIImage? {
        return cache.object(forKey: identifier)
    }
    
    func set(_ image: UIImage, forKey identifier: NSString) {
        cache.setObject(image, forKey: identifier)
    }
}

extension URLService {
    
    func request<T: Decodable>(url: URLLink, completion: ((T) -> Void)? = nil) {
        
        switch url {
        case .section:
            task = URLSession.shared.dataTask(with: url.urlValue) { data, res, err in
                
                if let err = err {
                    print("RequestError", err)
                    
                    return
                }
                
                guard
                    let response = res as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                else {
                    return
                }
                
                let decoder = JSONDecoder()
                
                DispatchQueue.main.async {
                    do {
                        let sections = try decoder.decode(SectionResponse.self, from: data)
                        
                        completion!(sections as! T)
                    } catch let error {
                        print("DecodingError", error)
                    }
                }
            }
        }
        
        task.resume()
    }
}
