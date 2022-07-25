//
//  URLService.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 17/04/2022.
//

import UIKit

// MARK: - URLService

final class URLService {
    
    // MARK: Properties
    
    static let shared: URLService = .init()
    
    
    let session: URLSession = .init(configuration: .default)
    
    private(set) var cache: NSCache<NSString, UIImage> = .init()
    
    private let queue: DispatchQueue = .init(label: "URLService", qos: .background)
    
    var configuration: URLSessionConfiguration {
        let configuration: URLSessionConfiguration = .background(withIdentifier: "URLService")
        configuration.timeoutIntervalForRequest = 30
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
