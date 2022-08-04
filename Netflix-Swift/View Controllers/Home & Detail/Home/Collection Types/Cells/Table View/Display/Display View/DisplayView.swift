//
//  DisplayView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 16/03/2022.
//

import UIKit

// MARK: - DisplayView

final class DisplayView: UIView, Nibable {
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    @IBOutlet private(set) weak var mediaDisplayView: MediaDisplayView! = nil
    @IBOutlet private(set) weak var panelView: PanelView! = nil
    
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNib()
    }
}
