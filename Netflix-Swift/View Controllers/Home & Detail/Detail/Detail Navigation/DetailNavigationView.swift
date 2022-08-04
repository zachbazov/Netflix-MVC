//
//  DetailNavigationView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 15/03/2022.
//

import UIKit

// MARK: - DetailNavigationViewDelegate

protocol DetailNavigationViewDelegate: AnyObject {
    func detailNavigationViewDidSetup(_ detailNavigationView: DetailNavigationView)
    func detailNavigationView(_ detailNavigationView: DetailNavigationView, stateDidChange state: DetailNavigationView.State)
}


// MARK: - DetailNavigationView

final class DetailNavigationView: UIView, Nibable {
    
    // MARK: State
    
    enum State: Int {
        case moreLikeThis,
             trailersNmore
    }
    
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    @IBOutlet private weak var leadingIndicator: UIView! = nil
    @IBOutlet private weak var leadingButton: UIView! = nil
    @IBOutlet private weak var trailingIndicator: UIView! = nil
    @IBOutlet private weak var trailingButton: UIView! = nil
    @IBOutlet private weak var leadingIndicatorWidthConstraint: NSLayoutConstraint! = nil
    @IBOutlet private weak var trailingIndicatorWidthConstraint: NSLayoutConstraint! = nil
    
    weak var delegate: DetailNavigationViewDelegate! = nil
    
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNib()
        self.delegate = self
        self.delegate.detailNavigationViewDidSetup(self)
    }
    
    
    // MARK: Action Outlets
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        guard
            let state: State = .init(rawValue: sender.tag),
            let delegate = delegate
        else { return }
        delegate.detailNavigationView(self, stateDidChange: state)
    }
}


// MARK: - DetailNavigationViewDelegate Implementation

extension DetailNavigationView: DetailNavigationViewDelegate {
    
    func detailNavigationViewDidSetup(_ detailNavigationView: DetailNavigationView) {
        let negativeWidth = -trailingButton.bounds.size.width
        detailNavigationView.leadingIndicatorWidthConstraint.constant = .zero
        detailNavigationView.trailingIndicatorWidthConstraint.constant = negativeWidth
    }
    
    func detailNavigationView(_ detailNavigationView: DetailNavigationView,
                              stateDidChange state: DetailNavigationView.State) {
        switch state {
        case .moreLikeThis:
            let negativeWidth = -trailingButton.bounds.size.width
            leadingIndicatorWidthConstraint.constant = .zero
            trailingIndicatorWidthConstraint.constant = negativeWidth
        case .trailersNmore:
            let negativeWidth = -leadingButton.bounds.size.width
            leadingIndicatorWidthConstraint.constant = negativeWidth
            trailingIndicatorWidthConstraint.constant = .zero
        }
        let duration = TimeInterval(0.5)
        UIView.animate(withDuration: duration) { [weak self] in
            guard let self = self else { return }
            self.contentView.layoutIfNeeded()
        }
    }
}
