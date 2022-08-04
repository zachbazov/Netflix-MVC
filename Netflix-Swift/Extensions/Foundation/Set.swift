//
//  Set.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 09/03/2022.
//

import Foundation

// MARK: ListKey

enum ListKey: String {
    case tvShows = "TVShowsMyListKey",
         movies = "MoviesMyListKey"
}



// MARK: - Set

extension Set where Element: Mediable {
    
    func encode(for key: ListKey) {
        do {
            UserDefaults.standard.set(try PropertyListEncoder().encode(self), forKey: key.rawValue)
        } catch {
            print(String(describing: error))
        }
    }
    
    mutating func decode(for key: ListKey) {
        guard let data = UserDefaults.standard.value(forKey: key.rawValue) as? Data else { return }
        self = try! PropertyListDecoder().decode(Set<Element>.self, from: data)
    }
}
