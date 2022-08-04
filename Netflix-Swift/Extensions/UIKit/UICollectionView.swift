//
//  UICollectionView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 06/06/2022.
//

import UIKit

// MARK: - UICollectionView

extension UICollectionView {
    
    func prepareForDequeue<T: Reusable>() -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: .first) as? T else {
            fatalError("Unable to dequeue cell of type \(T.reuseIdentifier).")
        }
        return cell
    }
    
    func dequeueReusableCell<T: Reusable>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue cell of type \(T.reuseIdentifier).")
        }
        return cell
    }
}
