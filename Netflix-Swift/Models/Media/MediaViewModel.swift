//
//  MediaViewModel.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 20/05/2022.
//

import UIKit

// MARK: - Mediable

protocol Mediable: Codable, Hashable {
    var id: String? { get }
}


// MARK: - MediaViewModel

public struct MediaViewModel: Mediable {
    
    // MARK: Shared Properties
    
    var id: String?
    var title: String?
    var rating: CGFloat?
    var description: String?
    var cast: String?
    var isHD: Bool?
    var displayCover: String?
    var detailCover: String?
    var logo: String?
    var hasWatched: Bool?
    var newRelease: Bool?
    var logoPosition: String?
    var slug: String?
    
    var genres: [String]?
    var trailers: [String]?
    var covers: [String]?
    
    
    // MARK: TV Show's Properties
    
    var duration: String?
    var seasonCount: Int?
    var episodeCount: Int?
    
    
    // MARK: Movie's Properties
    
    var year: Int?
    var length: String?
    var writers: String?
    var previewURL: String?
}


// MARK: - Equatable Implementation

extension MediaViewModel: Equatable {
    public static func ==(lhs: MediaViewModel, rhs: MediaViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}


// MARK: - Comparable Implementation

extension MediaViewModel: Comparable {
    public static func <(lhs: MediaViewModel, rhs: MediaViewModel) -> Bool {
        return lhs.title! < rhs.title!
    }
}
