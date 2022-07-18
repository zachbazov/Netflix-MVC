//
//  StandardTableViewCell.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 15/02/2022.
//

import UIKit

// MARK: - StandardTableViewCell

final class StandardTableViewCell: TableViewCell<StandardCollectionViewCell> {
    
    // MARK: Identifier

    @objc enum Identifier: Int, CaseIterable {
        case action = 3,
             sciFi,
             crime = 7,
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
            case .action: return "ActionCell"
            case .sciFi: return "SciFiCell"
            case .crime: return "CrimeCell"
            case .thriller: return "ThrillerCell"
            case .adventure: return "AdventureCell"
            case .comedy: return "ComedyCell"
            case .drama: return "DramaCell"
            case .horror: return "HorrorCell"
            case .anime: return "AnimeCell"
            case .familyNchildren: return "FamilyAndChildrenCell"
            case .documentary: return "DocumentaryCell"
            }
        }
    }
}
