//
//  LHCollectionTableViewSectionCell.swift
//  Storyboards
//
//  Created by 許立衡 on 2018/10/21.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit

open class LHCollectionTableViewSectionCell: UITableViewCell {

    @IBOutlet private weak var collectionView: UICollectionView!
    weak var dataSource: StoryboardViewSectionCellDataSource?
    weak var delegate: LHCollectionTableViewSectionCellDelegate?
    weak var dragDelegate: LHCollectionTableViewSectionCellDragDelegate?
    weak var dropDelegate: LHCollectionTableViewSectionCellDropDelegate?
    @IBOutlet internal weak var emptyStateView: UIView? {
        didSet {
            emptyStateView?.isHidden = collectionView.numberOfItems(inSection: 0) != 0
        }
    }
    
    var numberOfItems: () -> Int = { 0 }
    var configureCellAtIndexPath: (LHCollectionTableViewCell, IndexPath) -> Void = { _, _ in }
    var id: String = ""
    
    var contentOffset: CGPoint {
        get {
            return collectionView.contentOffset
        }
        set {
            collectionView.contentOffset = newValue
        }
    }
    
    open var isCollapsed: Bool {
        get {
            if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                return flowLayout.scrollDirection == .horizontal
            } else {
                return true
            }
        }
        set {
            if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                collectionView.isScrollEnabled = newValue
                flowLayout.scrollDirection = newValue ? .horizontal : .vertical
                delegate?.sectionCellDidToggleCollapsed(self)
            }
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
    
    func scrollToItem(at indexPath: IndexPath, animated: Bool, completion: ((Bool) -> Void)?) {
        collectionView.performBatchUpdates({
            self.collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally, .centeredVertically], animated: animated)
        }, completion: completion)
        
    }
    
    func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> LHCollectionTableViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! LHCollectionTableViewCell
    }
    
}
