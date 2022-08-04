//
//  PrototypeViewController.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 31/03/2022.
//

import UIKit

// MARK: - PrototypeViewController

class PrototypeViewController: UIViewController {
    
    // MARK: Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var shouldAutorotate: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    
    var segue: Segue = .init()
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segue.delegate = self
    }
}



// MARK: - SegueDelegate Implementation

extension PrototypeViewController: SegueDelegate {
    
    func performSegue(withIdentifier identifier: Segue.Identifier) {
        performSegue(withIdentifier: identifier.rawValue, sender: self)
    }
}
