//
//  MyList.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 20/04/2022.
//

import Foundation

// MARK: - MyListDelegate

protocol MyListDelegate: AnyObject {
    
    func insertAndEncode(_ media: MediaViewModel,
                         for key: ListKey,
                         insertObjectTo set: inout Set<MediaViewModel>)
    
    func removeAndEncode(_ media: MediaViewModel,
                         for key: ListKey,
                         insertObjectTo set: inout Set<MediaViewModel>)
    
    func shouldInsertOrRemove(_ media: MediaViewModel,
                              for key: ListKey,
                              insertObjectTo set: inout Set<MediaViewModel>)
}



// MARK: - MyList Class

final class MyList {
    
    // MARK: Properties
    
    var data: Set<MediaViewModel> = []
    
    
    // MARK: Initialization
    
    init(forKey key: ListKey) {
        data = []
        data.decode(for: key)
    }
}



// MARK: - MyListDelegate Implementation

extension MyList: MyListDelegate {
    
    func insertAndEncode(_ media: MediaViewModel, for key: ListKey, insertObjectTo set: inout Set<MediaViewModel>) {
        
        DispatchQueue.global(qos: .userInitiated).sync {
            set.insert(media)
            set.encode(for: key)
        }
    }
    
    func removeAndEncode(_ media: MediaViewModel, for key: ListKey, insertObjectTo set: inout Set<MediaViewModel>) {
        
        DispatchQueue.global(qos: .userInitiated).sync {
            set.decode(for: key)
            
            guard !set.isEmpty else {
                return
            }
            
            set.remove(media)
            set.encode(for: key)
        }
    }
    
    func shouldInsertOrRemove(_ media: MediaViewModel, for key: ListKey, insertObjectTo set: inout Set<MediaViewModel>) {
        
        DispatchQueue.global(qos: .userInitiated).sync {
            set.contains(media)
                ? removeAndEncode(media, for: key, insertObjectTo: &set)
                : insertAndEncode(media, for: key, insertObjectTo: &set)
        }
    }
}
