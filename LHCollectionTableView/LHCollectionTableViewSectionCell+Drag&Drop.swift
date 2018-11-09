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
        return dragDelegate?.sectionCell(self, itemsForBeginning: session, at: indexPath) ?? []
    }
    
    public func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return dragDelegate?.sectionCell(self, dragPreviewParametersForItemAt: indexPath)
    }
    
}

extension LHCollectionTableViewSectionCell: UICollectionViewDropDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return dropDelegate?.sectionCell(self, dropSessionDidUpdate: session, withDestinationIndexPath: destinationIndexPath) ?? UICollectionViewDropProposal(operation: .cancel)
    }
    
    public func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        dropDelegate?.sectionCell(self, performDropWith: coordinator)
    }
    
}
