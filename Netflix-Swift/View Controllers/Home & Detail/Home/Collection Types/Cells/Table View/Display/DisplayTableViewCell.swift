//
//  DisplayTableViewCell.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 13/04/2022.
//

import UIKit

// MARK: - DisplayTableViewCell

final class DisplayTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var displayView: DisplayView! = nil
    
    
    weak var homeViewController: HomeViewController! = nil
    
    
    // MARK: Deinitialization
    
    deinit {
        guard
            let mediaDisplayView = displayView.mediaDisplayView,
            let panelView = displayView.panelView,
            let leadingPanelButton = panelView.leadingPanelButton,
            let trailingPanelButton = panelView.trailingPanelButton
        else {
            return
        }
        
        WeakInjector.shared.eject([mediaDisplayView,
                                   panelView,
                                   leadingPanelButton,
                                   trailingPanelButton])
        
        homeViewController = nil
    }
}



// MARK: - Configurable Implementation

extension DisplayTableViewCell: Configurable {
    
    func configure(_ section: SectionViewModel? = nil, with homeViewController: HomeViewController? = nil) {
        self.homeViewController = homeViewController
        
        guard
            let homeViewController = homeViewController,
            let mediaDisplayView = displayView.mediaDisplayView,
            let panelView = displayView.panelView,
            let leadingPanelButton = panelView.leadingPanelButton,
            let trailingPanelButton = panelView.trailingPanelButton
        else {
            return
        }
        
        WeakInjector.shared.inject([mediaDisplayView,
                                   panelView,
                                   leadingPanelButton,
                                   trailingPanelButton],
                                   with: homeViewController)
    }
}
