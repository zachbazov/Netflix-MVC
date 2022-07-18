//
//  DetailPanelView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 15/03/2022.
//

import UIKit

// MARK: - DetailPanelView

final class DetailPanelView: UIView, Nibable {

    // MARK: Properties

    @IBOutlet weak var contentView: UIView! = nil
    
    @IBOutlet private(set) weak var leadingPanelButton: DetailPanelItemView! = nil
    
    @IBOutlet private weak var middlePanelButton: DetailPanelItemView! = nil
    
    @IBOutlet private(set) weak var trailingPanelButton: DetailPanelItemView! = nil
    
    
    weak var detailViewController: DetailViewController! = nil {
        didSet {
            guard let detailViewController = detailViewController else {
                return
            }
            
            WeakInjector.shared.inject([leadingPanelButton,
                                        middlePanelButton,
                                        trailingPanelButton],
                                       with: detailViewController)
        }
    }
    
    
    // MARK: Initialization & Deinitialization

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.loadNib()
    }
    
    deinit {
        WeakInjector.shared.eject([leadingPanelButton,
                                   middlePanelButton,
                                   trailingPanelButton])
        
        detailViewController = nil
    }
}
