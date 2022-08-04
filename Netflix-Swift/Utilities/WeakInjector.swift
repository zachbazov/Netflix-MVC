//
//  WeakInjector.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 21/06/2022.
//

import UIKit

// MARK: - WeakInjecting

private protocol WeakInjecting {
    func inject<T, C>(_ t: T, with c: C) where C: UIViewController
    func inject<T, C>(_ t: [T], with c: C) where C: UIViewController
    func eject<T>(_ t: T)
    func eject<T>(_ t: [T])
}


// MARK: - WeakInjector

final class WeakInjector {
    
    static var shared: WeakInjector = .init()
}


// MARK: WeakInjecting

extension WeakInjector: WeakInjecting {
    
    func inject<T, C>(_ t: T, with c: C) where C: UIViewController {
        switch t {
        case let alertView as AlertView:
            switch c {
            case let c as SignUpViewController:
                alertView.signUpViewController = c
            case let c as SignInViewController:
                alertView.signInViewController = c
            case let c as HomeViewController:
                alertView.homeViewController = c
            default: break
            }
        case let homeViewModel as HomeViewModel:
            homeViewModel.homeViewController = c as? HomeViewController
        case let navigationView as NavigationView:
            navigationView.homeViewController = c as? HomeViewController
        case let navigationOverlayView as NavigationOverlayView:
            navigationOverlayView.homeViewController = c as? HomeViewController
        case let navigationItem as NavigationItem:
            navigationItem.homeViewController = c as? HomeViewController
        case let mediaDisplayView as MediaDisplayView:
            mediaDisplayView.homeViewController = c as? HomeViewController
        case let panelView as PanelView:
            panelView.homeViewController = c as? HomeViewController
        case let panelItemView as PanelItemView:
            panelItemView.homeViewController = c as? HomeViewController
        case let homeOverlayViewController as HomeOverlayViewController:
            homeOverlayViewController.homeViewController = c as? HomeViewController
        case let detailViewController as DetailViewController:
            detailViewController.homeViewController = c as? HomeViewController
        case let detailViewModel as DetailViewModel:
            detailViewModel.detailViewController = c as? DetailViewController
        case let detailPreviewView as DetailPreviewView:
            detailPreviewView.detailViewController = c as? DetailViewController
        case let detailInfoView as DetailInfoView:
            detailInfoView.detailViewController = c as? DetailViewController
        case let detailDescriptionView as DetailDescriptionView:
            detailDescriptionView.detailViewController = c as? DetailViewController
        case let detailPanelView as DetailPanelView:
            detailPanelView.detailViewController = c as? DetailViewController
        case let mediaPlayerView as MediaPlayerView:
            mediaPlayerView.detailViewController = c as? DetailViewController
            mediaPlayerView.mediaOverlayView.mediaPlayerView = (c as? DetailViewController)?.detailPreviewView.mediaPlayerView
        case let detailPanelItemView as DetailPanelItemView:
            detailPanelItemView.detailViewController = c as? DetailViewController
        default: break
        }
    }
    
    func inject<T, C>(_ t: [T], with c: C) where C: UIViewController {
        for _t in t {
            inject(_t, with: c)
        }
    }
    
    func eject<T>(_ t: T) {
        switch t {
        case let homeViewModel as HomeViewModel:
            homeViewModel.homeViewController = nil
        case let navigationView as NavigationView:
            navigationView.homeViewController = nil
        case let navigationOverlayView as NavigationOverlayView:
            navigationOverlayView.homeViewController = nil
        case let navigationItem as NavigationItem:
            navigationItem.homeViewController = nil
        case let mediaDisplayView as MediaDisplayView:
            mediaDisplayView.homeViewController = nil
        case let panelView as PanelView:
            panelView.homeViewController = nil
        case let panelItemView as PanelItemView:
            panelItemView.homeViewController = nil
        case let homeOverlayViewController as HomeOverlayViewController:
            homeOverlayViewController.homeViewController = nil
        case let detailViewController as DetailViewController:
            detailViewController.homeViewController = nil
        case let detailViewModel as DetailViewModel:
            detailViewModel.detailViewController = nil
        case let detailPreviewView as DetailPreviewView:
            detailPreviewView.detailViewController = nil
        case let detailInfoView as DetailInfoView:
            detailInfoView.detailViewController = nil
        case let detailDescriptionView as DetailDescriptionView:
            detailDescriptionView.detailViewController = nil
        case let detailPanelView as DetailPanelView:
            detailPanelView.detailViewController = nil
        case let detailPanelItemView as DetailPanelItemView:
            detailPanelItemView.detailViewController = nil
        default: break
        }
    }
    
    func eject<T>(_ t: [T]) {
        for _t in t {
            eject(_t)
        }
    }
}
