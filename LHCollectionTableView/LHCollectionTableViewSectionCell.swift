//
//  LHCollectionTableViewSectionCell.swift
//  Storyboards
//
//  Created by 許立衡 on 2018/10/21.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit

protocol StoryboardViewSectionCellDataSource: AnyObject {
    func numberOfItems(for sectionCell: LHCollectionTableViewSectionCell) -> Int
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, cellForItemAt indexPath: IndexPath) -> LHCollectionTableViewCell
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, canMoveItemAt indexPath: IndexPath) -> Bool
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, moveItemAt fromIndexPath: IndexPath, toIndexPath: IndexPath)
}

protocol StoryboardViewSectionCellDelegate: AnyObject {
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, canPerformAction action: Selector, forItemAt indexPath: IndexPath) -> Bool
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, performAction action: Selector, forItemAt indexPath: IndexPath)
}

open class LHCollectionTableViewSectionCell: UITableViewCell {

    @IBOutlet private weak var collectionView: UICollectionView!
    weak var dataSource: StoryboardViewSectionCellDataSource?
    weak var delegate: StoryboardViewSectionCellDelegate?
    @IBOutlet private weak var emptyStateView: UIView? {
        didSet {
            emptyStateView?.isHidden = collectionView.numberOfItems(inSection: 0) != 0
        }
    }
    
    var contentOffset: CGPoint {
        get {
            return collectionView.contentOffset
        }
        set {
            collectionView.contentOffset = newValue
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func cellForItem(at indexPath: IndexPath) -> LHCollectionTableViewCell? {
        return collectionView.cellForItem(at: indexPath) as? LHCollectionTableViewCell
    }
    
    func indexPath(for cell: LHCollectionTableViewCell) -> IndexPath? {
        return collectionView.indexPath(for: cell)
    }
    
    func indexPathForItem(at location: CGPoint) -> IndexPath? {
        return collectionView.indexPathForItem(at: convert(location, to: collectionView))
    }

    func insertItems(at indexPaths: [IndexPath]) {
        collectionView.insertItems(at: indexPaths)
    }
    
    func reloadItem(indexPaths: [IndexPath]) {
        collectionView.reloadItems(at: indexPaths)
    }
    
    func moveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        collectionView.deleteItems(at: indexPaths)
    }
    
    func scrollToItem(at indexPath: IndexPath, animated: Bool) {
        collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally, .centeredVertically], animated: animated)
    }
    
    func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> LHCollectionTableViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! LHCollectionTableViewCell
    }
    
}

extension LHCollectionTableViewSectionCell: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemCount = dataSource?.numberOfItems(for: self) ?? 0
        emptyStateView?.isHidden = itemCount != 0
        return itemCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource!.sectionCell(self, cellForItemAt: indexPath)
    }
    
}

extension LHCollectionTableViewSectionCell: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return delegate?.sectionCell(self, canPerformAction: action, forItemAt: indexPath) ?? false
    }
    
    public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        delegate?.sectionCell(self, performAction: action, forItemAt: indexPath)
    }
    
}

extension LHCollectionTableViewSectionCell: UICollectionViewDragDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard dataSource?.sectionCell(self, canMoveItemAt: indexPath) == true else { return [] }
        if let section = (superview as? UITableView)?.indexPath(for: self)?.row {
            let item = UIDragItem(itemProvider: NSItemProvider())
            item.localObject = IndexPath(item: indexPath.item, section: section)
            return [item]
        }
        return []
    }
    
    public func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let preview = UIDragPreviewParameters()
        let cell = collectionView.cellForItem(at: indexPath)!
        preview.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 5)
        return preview
    }
    
}

extension LHCollectionTableViewSectionCell: UICollectionViewDropDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if let dragSession = session.localDragSession,
            let item = dragSession.items.first,
            item.localObject is IndexPath {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .cancel)
    }
    
    public func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let dropItem = coordinator.items.first else { return }
        let itemCount = collectionView.numberOfItems(inSection: 0)
        var destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: itemCount, section: 0)
        guard let section = (superview as? UITableView)?.indexPath(for: self)?.row else { return }
        destinationIndexPath.section = section
        let item = dropItem.dragItem
        if let sourceIndexPath = item.localObject as? IndexPath {
            if sourceIndexPath.section == destinationIndexPath.section,
                destinationIndexPath.item == itemCount {
                destinationIndexPath.item -= 1
            }
            dataSource?.sectionCell(self, moveItemAt: sourceIndexPath, toIndexPath: destinationIndexPath)
            destinationIndexPath.section = 0
            coordinator.drop(item, toItemAt: destinationIndexPath)
        }
    }
    
}
