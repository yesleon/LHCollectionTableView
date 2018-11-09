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

    @IBOutlet private weak var tableView: UITableView!
    internal var cellContentOffsets: [IndexPath : CGPoint] = [:]
    open weak var dataSource: LHCollectionTableViewDataSource?
    open weak var delegate: LHCollectionTableViewDelegate?
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
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.setHandlesKeyboard(true)
    }
    
    deinit {
        tableView.setHandlesKeyboard(false)
    }
    
    open func reloadData() {
        tableView.reloadData()
    }
    
    // MARK: Section
    
    open func sectionCell(at section: Int) -> LHCollectionTableViewSectionCell? {
        return tableView.cellForRow(at: IndexPath(row: section, section: 0)) as? LHCollectionTableViewSectionCell
    }
    
    open func section(for sectionCell: LHCollectionTableViewSectionCell) -> Int? {
        return tableView.indexPath(for: sectionCell)?.row
    }
    
    open func insertSection(at section: Int, with animation: UITableView.RowAnimation) {
        tableView.insertRows(at: [IndexPath(row: section, section: 0)], with: animation)
    }
    
    open func moveSection(_ section: Int, toSection: Int) {
        tableView.moveRow(at: IndexPath(row: section, section: 0), to: IndexPath(row: toSection, section: 0))
    }
    
    open func deleteSection(_ section: Int, with animation: UITableView.RowAnimation) {
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
        guard let sectionCell = self.sectionCell(at: indexPath.section) else { fatalError("No such section.") }
        sectionCell.insertItems(at: [IndexPath(item: indexPath.item, section: 0)])
    }
    
    open func moveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceSectionCell = sectionCell(at: sourceIndexPath.section)
        let destinationSectionCell = sectionCell(at: destinationIndexPath.section)
        
        if sourceSectionCell === destinationSectionCell {
            sourceSectionCell?.moveItem(at: IndexPath(item: sourceIndexPath.item, section: 0), to: IndexPath(item: destinationIndexPath.item, section: 0))
        } else {
            sourceSectionCell?.deleteItems(at: [IndexPath(item: sourceIndexPath.item, section: 0)])
            destinationSectionCell?.insertItems(at: [IndexPath(item: destinationIndexPath.item, section: 0)])
        }
    }
    
    open func deleteItem(at indexPath: IndexPath) {
        guard let sectionCell = self.sectionCell(at: indexPath.section) else { fatalError("No such section.") }
        sectionCell.deleteItems(at: [IndexPath(item: indexPath.item, section: 0)])
    }
    
    open func scrollToItem(at indexPath: IndexPath, animated: Bool) {
        scrollToSection(indexPath.section, animated: false)
        guard let sectionCell = self.sectionCell(at: indexPath.section) else { return }
        sectionCell.scrollToItem(at: IndexPath(item: indexPath.item, section: 0), animated: animated)
    }

}
