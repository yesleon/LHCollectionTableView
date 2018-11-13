//
//  LHCollectionTableView+Drag&Drop.swift
//  LHCollectionTableView
//
//  Created by 許立衡 on 2018/11/9.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import Foundation

public protocol LHCollectionTableViewDragDelegate: AnyObject {
    func collectionTableView(_ collectionTableView: LHCollectionTableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    func collectionTableView(_ collectionTableView: LHCollectionTableView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters?
    func collectionTableView(_ collectionTableView: LHCollectionTableView, dragSessionWillBegin session: UIDragSession)
    func collectionTableView(_ collectionTableView: LHCollectionTableView, dragSessionDidEnd session: UIDragSession)
}

public protocol LHCollectionTableViewDropDelegate: AnyObject {
    func collectionTableView(_ collectionTableView: LHCollectionTableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> LHCollectionTableViewDropProposal
    func collectionTableView(_ collectionTableView: LHCollectionTableView, performDropWith coordinator: LHCollectionTableViewDropCoordinator)
}


extension LHCollectionTableView: UITableViewDragDelegate {
    
    open func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
}

extension LHCollectionTableView: UITableViewDropDelegate {
    
    open func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .cancel)
    }
    
    open func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }
    
}

extension LHCollectionTableView: LHCollectionTableViewSectionCellDragDelegate {
    
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, dragSessionWillBegin session: UIDragSession) {
        dragDelegate?.collectionTableView(self, dragSessionWillBegin: session)
    }
    
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, dragSessionDidEnd session: UIDragSession) {
        dragDelegate?.collectionTableView(self, dragSessionDidEnd: session)
    }
    
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let section = self.section(for: sectionCell) else { return [] }
        let indexPath = IndexPath(item: indexPath.item, section: section)
        return dragDelegate?.collectionTableView(self, itemsForBeginning: session, at: indexPath) ?? []
    }
    
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let section = self.section(for: sectionCell) else { return nil }
        let indexPath = IndexPath(item: indexPath.item, section: section)
        return dragDelegate?.collectionTableView(self, dragPreviewParametersForItemAt: indexPath)
    }
    
}

extension LHCollectionTableView: LHCollectionTableViewSectionCellDropDelegate {
    
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> LHCollectionTableViewDropProposal {
        guard let section = self.section(for: sectionCell) else { return LHCollectionTableViewDropProposal(operation: .cancel) }
        var indexPath = destinationIndexPath
        indexPath?.section = section
        return dropDelegate?.collectionTableView(self, dropSessionDidUpdate: session, withDestinationIndexPath: destinationIndexPath) ?? LHCollectionTableViewDropProposal(operation: .cancel)
    }
    
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, performDropWith coordinator: LHCollectionTableViewDropCoordinator) {
        guard let section = self.section(for: sectionCell) else { return }
        guard let itemCount = dataSource?.collectionTableView(self, numberOfItemsInSection: section) else { return }
        
        let coordinator = CollectionTableViewDropCoordinator(coordinator, section: section, itemCount: itemCount)
        dropDelegate?.collectionTableView(self, performDropWith: coordinator)
    }
    
}
