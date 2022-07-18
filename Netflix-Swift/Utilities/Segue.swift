//
//  Segue.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 31/03/2022.
//

import UIKit

// MARK: - SegueDelegate

protocol SegueDelegate: AnyObject {
    func performSegue(withIdentifier identifier: Segue.Identifier)
}



// MARK: - Segue

final class Segue {
    
    // MARK: Identifier
    
    enum Identifier: String {
        case detail = "DetailViewController"
        case homeOverlay = "HomeOverlayViewController"
    }
    
    
    // MARK: Properties
    
    weak var delegate: SegueDelegate! = nil
    
    
    var current: Identifier {
        didSet {
            perform()
        }
    }
    
    
    // MARK: Initialization
    
    init() {
        self.current = .detail
    }
    
    
    // MARK: SegueDelegate Invocation Methods
    
    func perform() {
        guard let delegate = delegate else {
            return
        }
        
        delegate.performSegue(withIdentifier: current)
    }
}
