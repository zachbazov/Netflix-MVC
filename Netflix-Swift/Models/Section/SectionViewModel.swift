//
//  SectionViewModel.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 19/03/2022.
//

import UIKit

// MARK: - Sectionable

protocol Sectionable: Decodable {
    var id: Int { get }
    var title: String { get }
    var media: [MediaViewModel] { get set }
}



// MARK: - SectionViewModel

@objc class SectionViewModel: NSObject, Decodable, Sectionable {
    
    // MARK: Properties
    
    var id: Int
    var title: String
    var media: [MediaViewModel]
    var movies: [MediaViewModel]
    
    
    // MARK: Intialization
    
    init(id: Int? = nil, title: String? = nil, media: [MediaViewModel]? = nil, movies: [MediaViewModel]? = nil) {
        self.id = id ?? 0
        self.title = title ?? ""
        self.media = media ?? []
        self.movies = movies ?? []
    }
}



// MARK: - SectionIndices

enum SectionIndices: Int, Valuable, CaseIterable {
    
    case display,
         ratable,
         resumable,
         action,
         sciFi,
         blockbuster,
         myList,
         crime,
         thriller,
         adventure,
         comedy,
         drama,
         horror,
         anime,
         familyNchildren,
         documentary
    
    var stringValue: String {
        switch self {
        case .display,
                .ratable,
                .resumable,
                .myList:
            return ""
        case .action: return "Action"
        case .sciFi: return "Sci-Fi"
        case .blockbuster: return "Blockbusters"
        case .crime: return "Crime"
        case .thriller: return "Thriller"
        case .adventure: return "Adventure"
        case .comedy: return "Comedy"
        case .drama: return "Drama"
        case .horror: return "Horror"
        case .anime: return "Anime"
        case .familyNchildren: return "Family & Children"
        case .documentary: return "Documentary"
        }
    }
}
