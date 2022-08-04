//
//  ComputableFlowLayout.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 28/01/2022.
//

import UIKit

// MARK: - Computable

protocol Computable {
    var itemsPerLine: Int { get }
    var lines: Int { get }
    var width: CGFloat { get }
    var height: CGFloat { get }
    var cellSpacing: CGFloat { get }
    var lineSpacing: CGFloat { get }
}


// MARK: - ComputableFlowLayout

open class ComputableFlowLayout: UICollectionViewFlowLayout, Computable {
    
    // MARK: State
    
    enum State {
        case original, blockbuster, standard, homeOverlay, detail
    }
    
    
    // MARK: ScrollDirection
    
    enum ScrollDirection {
        case horizontal, vertical
    }
    
    
    // MARK: Properties
    
    private var state: State = .original
    
    open var itemsPerLine: Int = 3
    open var lines: Int = 1
    open var cellSpacing: CGFloat {
        get {
            switch state {
            case .detail:
                return 4.0
            default:
                return 8.0
            }
        }
        set {}
    }
    open var lineSpacing: CGFloat = 8.0
    
    var width: CGFloat {
        get {
            switch state {
            case .detail:
                return collectionView!.bounds.width / .init(itemsPerLine) - cellSpacing
            case .homeOverlay:
                return (collectionView!.bounds.width / .init(lines)) - (lineSpacing * .init(itemsPerLine))
            case .blockbuster:
                return collectionView!.bounds.width / .init(itemsPerLine)
            default:
                return collectionView!.bounds.width / .init(itemsPerLine)
            }
        }
        set {}
    }
    var height: CGFloat {
        get {
            switch state {
            case .homeOverlay,
                    .detail:
                return 160.0
            default:
                return collectionView!.bounds.height
            }
        }
        set {}
    }
    
    
    // MARK: Initialization
    
    convenience init(_ state: State, _ scrollDirection: ScrollDirection? = .horizontal) {
        self.init()
        self.state = state
        self.scrollDirection = scrollDirection == .horizontal ? .horizontal : .vertical
    }
    
    
    // MARK: Lifecycle
    
    open override func prepare() {
        super.prepare()
        minimumLineSpacing = .zero
        minimumInteritemSpacing = .zero
        sectionInset = .zero
        itemSize = .init(width: width, height: height - lineSpacing)
        switch state {
        case .detail:
            minimumLineSpacing = lineSpacing
            minimumInteritemSpacing = cellSpacing
            itemSize = .init(width: width, height: height)
        case .original:
            break
        case .blockbuster:
            minimumLineSpacing = lineSpacing
        case .standard:
            minimumLineSpacing = lineSpacing
            itemSize = .init(width: width - (6.0 * .init(itemsPerLine)),
                             height: height - lineSpacing)
        case .homeOverlay:
            minimumLineSpacing = lineSpacing * 2.0
            sectionInset = .init(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
            itemSize = .init(width: (width / .init(itemsPerLine)) - cellSpacing,
                             height: height)
        }
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let oldBounds = collectionView!.bounds as CGRect?,
           oldBounds.size != newBounds.size {
            return true
        }
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
}
