//
//  APIEndpoint.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 21/07/2022.
//

import Foundation

// MARK: - Endpoint

struct Endpoint {
    
    let path: String
    let queryItems: [URLQueryItem]
    
    let scheme: String = "https"
    let host: String = "netflix-swift-api.herokuapp.com"
}



extension Endpoint {
    
    // MARK: Sorting

    enum Sorting: String {
        case rating
    }
    
    
    // MARK: Path
    
    enum Path: String {
        case sections = "/api/v1/sections"
    }
    
    
    // MARK: Methods
    
    static func find(_ path: Path) -> Endpoint {
        return Endpoint(path: path.rawValue, queryItems: [])
    }
    
    static func find(matching query: String, sortedBy sorting: Sorting = .rating) -> Endpoint {
        return .init(path: "/api/v1/sections", queryItems: [])
    }
}



extension Endpoint {
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        
        return components.url
    }
}



extension URL {
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        
        self = url
    }
}
