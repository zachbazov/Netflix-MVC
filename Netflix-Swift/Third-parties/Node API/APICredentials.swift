//
//  APICredentials.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 20/07/2022.
//

import Foundation

// MARK: - APICredentials

final class APICredentials {
    
    // MARK: Properties
    
    static var kUser: String = "apiservice.authentication.user"
    
    static var kJWT: String = "apiservice.authentication.jwt"
    
    
    let defaults: UserDefaults = UserDefaults.standard
    
    
    var jwt: JWT! = nil
    
    var user: UserViewModel! = nil
    
    
    // MARK: Initialization
    
    init(jwt: JWT?, user: UserViewModel?) {
        self.jwt = jwt
        self.user = user
    }
    
    
    // MARK: Methods
    
    func deleteCache() {
        defaults.removeObject(forKey: APICredentials.kUser)
        defaults.removeObject(forKey: APICredentials.kJWT)
    }
    
    func decode() {
        do {
            guard
                let userData = defaults.value(forKey: APICredentials.kUser) as? Data,
                let token = defaults.string(forKey: APICredentials.kJWT)
            else {
                return
            }
            
            let decoder: PropertyListDecoder = .init()
            
            let jwt: JWT = .init(token: token)
            
            let user: UserViewModel = try decoder.decode(UserViewModel.self, from: userData)
            
            APIService.shared.authentication.credentials = .init(jwt: jwt, user: user)
            
        } catch let err {
            print(err.localizedDescription)
        }
    }
}
