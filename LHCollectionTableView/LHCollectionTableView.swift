//
//  LHCollectionTableView.swift
//  Storyboards
//
//  Created by 許立衡 on 2018/10/21.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit
import LHConvenientMethods

open class LHCollectionTableView: UIView {

    @IBOutlet private weak var tableView: UITableView! {
        willSet {
            newValue.dataSource = self
            newValue.delegate = self
            newValue.dragDelegate = self
            newValue.dropDelegate = self
            newValue.dragInteractionEnabled = true
            newValue.setHandlesKeyboard(true)
        }
    }
    internal var cellContentOffsets: [String : CGPoint] = [:]
    internal var cellIsCollapsed: [String : Bool] = [:]
    internal var cellIDs: [String] = []
    open weak var dataSource: LHCollectionTableViewDataSource?
    open weak var delegate: LHCollectionTableViewDelegate?
    open weak var dragDelegate: LHCollectionTableViewDragDelegate?
    open weak var dropDelegate: LHCollectionTableViewDropDelegate?
    open var headerView: UIView? {
        get {
            return tableView.tableHeaderView
        }
        set {
            tableView.tableHeaderView = newValue
        }
    }
    open var footerView: UIView? {
        get {
            return tableView.tableFooterView
        }
        set {
            tableView.tableFooterView = newValue
        }
    }
    open var emptyStateView: UIView? {
        didSet {
            if let emptyStateView = emptyStateView {
                emptyStateView.isHidden = tableView.numberOfRows(inSection: 0) != 0
                emptyStateView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                emptyStateView.frame = tableView.frame
                emptyStateView.translatesAutoresizingMaskIntoConstraints = true
                tableView.insertSubview(emptyStateView, at: 0)
            }
        }
    }
    
    var didScrollHandler: (() -> Void)?
    
    deinit {
        tableView.setHandlesKeyboard(false)
    }
    
    open func reloadData() {
        tableView.reloadData()
        cellContentOffsets.removeAll()
        cellIsCollapsed.removeAll()
    }
    
    func autoresizeRowHeight(animated: Bool) {
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100000))
        tableView.performBatchUpdates({
            if !animated {
                CATransaction.setDisableActions(true)
            }
        }) { _ in
            self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

        }
    }
    
    // MARK: Section
    
    open func sectionCell(at section: Int) -> LHCollectionTableViewSectionCell? {
        return tableView.cellForRow(at: IndexPath(row: section, section: 0)) as? LHCollectionTableViewSectionCell
    }
    
    open func section(for sectionCell: LHCollectionTableViewSectionCell) -> Int? {
        return tableView.indexPath(for: sectionCell)?.row
    }
    
    open func insertSection(at section: Int, with animation: UITableView.RowAnimation) {
        cellIDs.insert(UUID().uuidString, at: section)
        tableView.insertRows(at: [IndexPath(row: section, section: 0)], with: animation)
    }
    
    open func moveSection(_ section: Int, toSection: Int) {
        cellIDs.insert(cellIDs.remove(at: section), at: toSection)
        tableView.moveRow(at: IndexPath(row: section, section: 0), to: IndexPath(row: toSection, section: 0))
    }
    
    open func deleteSection(_ section: Int, with animation: UITableView.RowAnimation) {
        cellIDs.remove(at: section)
        tableView.deleteRows(at: [IndexPath(row: section, section: 0)], with: animation)
    }
    
    open func scrollToSection(_ section: Int, animated: Bool) {
        tableView.scrollToRow(at: IndexPath(row: section, section: 0), at: .none, animated: animated)
    }
    
    // MARK: Item
    
    open func indexPathForItem(at location: CGPoint) -> IndexPath? {
        guard let sectionCellIndexPath = tableView.indexPathForRow(at: convert(location, to: tableView)) else { return nil }
        guard let sectionCell = tableView.cellForRow(at: sectionCellIndexPath) as? LHCollectionTableViewSectionCell else { return nil }
        guard let itemIndexPath = sectionCell.indexPathForItem(at: convert(location, to: sectionCell)) else { return nil }
        return IndexPath(item: itemIndexPath.item, section: sectionCellIndexPath.row)
    }
    
    open func cellForItem(at indexPath: IndexPath) -> LHCollectionTableViewCell? {
        guard let sectionCell = sectionCell(at: indexPath.section) else { return nil }
        return sectionCell.cellForItem(at: IndexPath(item: indexPath.item, section: 0))
    }
    
    open func reloadItem(at indexPath: IndexPath) {
        guard let sectionCell = sectionCell(at: indexPath.section) else { return }
        sectionCell.reloadItem(indexPaths: [IndexPath(item: indexPath.item, section: 0)])
    }
    
    open func indexPath(for cell: LHCollectionTableViewCell) -> IndexPath? {
        for sectionCell in tableView.visibleCells.compactMap({ $0 as? LHCollectionTableViewSectionCell }) {
            if let indexPath = sectionCell.indexPath(for: cell) {
                let section = self.section(for: sectionCell)!
                return IndexPath(item: indexPath.item, section: section)
            }
        }
        return nil
    }
    
    open func insertItem(at indexPath: IndexPath) {
        guard let sectionCell = self.sectionCell(at: indexPath.section) else { return }
        sectionCell.insertItems(at: [IndexPath(item: indexPath.item, section: 0)])
        autoresizeRowHeight(animated: false)
    }
    
    open func moveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceSectionCell = sectionCell(at: sourceIndexPath.section)
        let destinationSectionCell = sectionCell(at: destinationIndexPath.section)
        
        if sourceSectionCell === destinationSectionCell {
            sourceSectionCell?.moveItem(at: IndexPath(item: sourceIndexPath.item, section: 0), to: IndexPath(item: destinationIndexPath.item, section: 0))
        } else {
            sourceSectionCell?.deleteItems(at: [IndexPath(item: sourceIndexPath.item, section: 0)])
            destinationSectionCell?.insertItems(at: [IndexPath(item: destinationIndexPath.item, section: 0)])
            autoresizeRowHeight(animated: false)
        }
    }
    
    open func deleteItem(at indexPath: IndexPath) {
        guard let sectionCell = self.sectionCell(at: indexPath.section) else { return }
        sectionCell.deleteItems(at: [IndexPath(item: indexPath.item, section: 0)])
        autoresizeRowHeight(animated: false)
    }
    
    open func scrollToItem(at indexPath: IndexPath, animated: Bool, completion: (() -> Void)? = nil) {
        tableView.performBatchUpdates({
            self.tableView.scrollToRow(at: IndexPath(row: indexPath.section, section: 0), at: .none, animated: animated)
            CATransaction.setCompletionBlock {
                guard let sectionCell = self.sectionCell(at: indexPath.section) else { return }
                let itemIndexPath = IndexPath(item: indexPath.item, section: 0)
                if sectionCell.isCollapsed {
                    sectionCell.scrollToItem(at: itemIndexPath, animated: animated, completion: completion)
                } else {
                    guard var itemFrame = sectionCell.rectForItem(at: itemIndexPath) else { return }
                    itemFrame = sectionCell.convert(itemFrame, to: self.tableView)
                    self.tableView.scrollRectToVisible(itemFrame, animated: true)
                    self.didScrollHandler = completion
                }
            }
        })
    }

}
