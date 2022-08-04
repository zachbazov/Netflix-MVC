//
//  PanelView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 13/02/2022.
//

import UIKit

// MARK: - PanelViewDelegate

protocol PanelViewDelegate: AnyObject {
    func panelViewDidConfigureButton(_ panelView: PanelView)
}


// MARK: - PanelView

final class PanelView: UIView, Nibable {
    
    // MARK: Item
    
    private enum Item: Int {
        case play = 2
    }
    
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    @IBOutlet private weak var playButton: UIButton! = nil
    @IBOutlet private(set) weak var leadingPanelButton: PanelItemView! = nil
    @IBOutlet private(set) weak var trailingPanelButton: PanelItemView! = nil
    
    weak var delegate: PanelViewDelegate! = nil
    
    weak var homeViewController: HomeViewController! = nil {
        didSet {
            guard let delegate = delegate else { return }
            delegate.panelViewDidConfigureButton(self)
        }
    }
    
    
    // MARK: Initialization & Deintialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNib()
        self.delegate = self
    }
    
    deinit {
        delegate = nil
        homeViewController = nil
    }
    
    
    // MARK: Methods
    
    @IBAction func playDidTap(_ sender: UIButton) {
        guard
            let item = Item(rawValue: sender.tag),
            let homeViewController = homeViewController
        else { return }
        if item == .play {
            homeViewController.homeViewModel.detailMedia = homeViewController.homeViewModel.displayMedia
            homeViewController.segue.current = .detail
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
}


// MARK: - PanelViewDelegate Implementation

extension PanelView: PanelViewDelegate {
    
    func panelViewDidConfigureButton(_ panelView: PanelView) {
        guard let homeViewController = homeViewController else { return }
        homeViewController.homeViewModel.currentSnapshot == .tvShows
            ? playButton.setTitle("Play", for: .normal)
            : playButton.setTitle("Trailer", for: .normal)
    }
}
