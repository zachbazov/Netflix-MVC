//
//  IntroViewController.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 19/07/2022.
//

import UIKit

// MARK: - IntroViewController

final class IntroViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var topGradientView: UIView!
    
    @IBOutlet weak var bottomGradientView: UIView!
    
    @IBOutlet weak var statusBarBackgroundView: StatusBarBackgroundView! = nil
    
    @IBOutlet weak var statusBarBackgroundGradientView: UIView! = nil
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topGradientView.addGradientLayer(frame: self.topGradientView.bounds,
                                              colors:
                                                [.clear,
                                                 .black.withAlphaComponent(0.75),
                                                 .black.withAlphaComponent(0.9)],
                                              locations: [0.0, 0.5, 1.0])
        
        self.bottomGradientView.addGradientLayer(frame: self.bottomGradientView.bounds,
                                              colors:
                                                [.black.withAlphaComponent(0.9),
                                                 .black.withAlphaComponent(0.75),
                                                 .clear],
                                              locations: [0.0, 0.5, 1.0])
        
        self.statusBarBackgroundGradientView.addGradientLayer(frame: self.statusBarBackgroundGradientView.bounds,
                                              colors:
                                                [.black.withAlphaComponent(0.75),
                                                 .black.withAlphaComponent(0.5),
                                                 .clear],
                                              locations: [0.0, 0.5, 1.0])
    }
}
