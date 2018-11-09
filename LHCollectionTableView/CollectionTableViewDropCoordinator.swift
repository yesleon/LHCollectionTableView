//
//  CollectionTableViewDropCoordinator.swift
//  LHCollectionTableView
//
//  Created by 許立衡 on 2018/11/9.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import Foundation


class CollectionTableViewDropCoordinator: NSObject {
    
    private let coordinator: UICollectionViewDropCoordinator
    private let section: Int
    private let itemCount: Int
    internal init(_ coordinator: UICollectionViewDropCoordinator, section: Int, itemCount: Int) {
        self.coordinator = coordinator
        self.section = section
        self.itemCount = itemCount
    }
    
}

extension CollectionTableViewDropCoordinator: UICollectionViewDropCoordinator {
    
    var destinationIndexPath: IndexPath? {
        return IndexPath(item: coordinator.destinationIndexPath?.item ?? itemCount, section: section)
    }
    
    var items: [UICollectionViewDropItem] {
        return coordinator.items
    }
    
    var proposal: UICollectionViewDropProposal {
        return coordinator.proposal
    }
    
    var session: UIDropSession {
        return coordinator.session
    }
    
    func drop(_ dragItem: UIDragItem, to placeholder: UICollectionViewDropPlaceholder) -> UICollectionViewDropPlaceholderContext {
        return coordinator.drop(dragItem, to: placeholder)
    }
    
    func drop(_ dragItem: UIDragItem, toItemAt indexPath: IndexPath) -> UIDragAnimating {
        let indexPath = IndexPath(item: indexPath.item, section: 0)
        return coordinator.drop(dragItem, toItemAt: indexPath)
    }
    
    func drop(_ dragItem: UIDragItem, intoItemAt indexPath: IndexPath, rect: CGRect) -> UIDragAnimating {
        let indexPath = IndexPath(item: indexPath.item, section: 0)
        return coordinator.drop(dragItem, intoItemAt: indexPath, rect: rect)
    }
    
    func drop(_ dragItem: UIDragItem, to target: UIDragPreviewTarget) -> UIDragAnimating {
        return coordinator.drop(dragItem, to: target)
    }
    
}
