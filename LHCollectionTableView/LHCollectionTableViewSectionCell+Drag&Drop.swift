//
//  LHCollectionTableViewSectionCell+Drag&Drop.swift
//  LHCollectionTableView
//
//  Created by 許立衡 on 2018/11/9.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import Foundation

public typealias LHCollectionTableViewDropProposal = UICollectionViewDropProposal
public typealias LHCollectionTableViewDropCoordinator = UICollectionViewDropCoordinator

protocol LHCollectionTableViewSectionCellDragDelegate: AnyObject {
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters?
}

protocol LHCollectionTableViewSectionCellDropDelegate: AnyObject {
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> LHCollectionTableViewDropProposal
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, performDropWith coordinator: LHCollectionTableViewDropCoordinator)
}

extension LHCollectionTableViewSectionCell: UICollectionViewDragDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        guard dataSource?.sectionCell(self, canMoveItemAt: indexPath) == true else { return [] }
//        if let section = (superview as? UITableView)?.indexPath(for: self)?.row {
//            let item = UIDragItem(itemProvider: NSItemProvider())
//            item.localObject = IndexPath(item: indexPath.item, section: section)
//            return [item]
//        }
//        return []
        return dragDelegate?.sectionCell(self, itemsForBeginning: session, at: indexPath) ?? []
    }
    
    public func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
//        let preview = UIDragPreviewParameters()
//        let cell = collectionView.cellForItem(at: indexPath)!
//        preview.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 5)
//        return preview
        return dragDelegate?.sectionCell(self, dragPreviewParametersForItemAt: indexPath)
    }
    
}

extension LHCollectionTableViewSectionCell: UICollectionViewDropDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
//        if let dragSession = session.localDragSession,
//            let item = dragSession.items.first,
//            item.localObject is IndexPath {
//            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
//        }
//        return UICollectionViewDropProposal(operation: .cancel)
        return dropDelegate?.sectionCell(self, dropSessionDidUpdate: session, withDestinationIndexPath: destinationIndexPath) ?? UICollectionViewDropProposal(operation: .cancel)
    }
    
    public func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
//        guard let dropItem = coordinator.items.first else { return }
//        let itemCount = collectionView.numberOfItems(inSection: 0)
//        var destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: itemCount, section: 0)
//        guard let section = (superview as? UITableView)?.indexPath(for: self)?.row else { return }
//        destinationIndexPath.section = section
//        let item = dropItem.dragItem
//        if let sourceIndexPath = item.localObject as? IndexPath {
//            if sourceIndexPath.section == destinationIndexPath.section,
//                destinationIndexPath.item == itemCount {
//                destinationIndexPath.item -= 1
//            }
//            dataSource?.sectionCell(self, moveItemAt: sourceIndexPath, toIndexPath: destinationIndexPath)
//            destinationIndexPath.section = 0
//            coordinator.drop(item, toItemAt: destinationIndexPath)
//        }
        dropDelegate?.sectionCell(self, performDropWith: coordinator)
    }
    
}
