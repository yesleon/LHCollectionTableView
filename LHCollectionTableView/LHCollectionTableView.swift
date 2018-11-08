//
//  LHCollectionTableView.swift
//  Storyboards
//
//  Created by 許立衡 on 2018/10/21.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit
import LHConvenientMethods


public protocol LHCollectionTableViewDataSource: AnyObject {
    func numberOfSections(in collectionTableView: LHCollectionTableView) -> Int
    func collectionTableView(_ collectionTableView: LHCollectionTableView, numberOfItemsInSection section: Int) -> Int
    func collectionTableView(_ collectionTableView: LHCollectionTableView, configure cell: LHCollectionTableViewCell, forItemAt indexPath: IndexPath)
    func collectionTableView(_ collectionTableView: LHCollectionTableView, configure sectionCell: LHCollectionTableViewSectionCell, forSection section: Int)
    func collectionTableView(_ collectionTableView: LHCollectionTableView, canMoveSection section: Int) -> Bool
    func collectionTableView(_ collectionTableView: LHCollectionTableView, moveSection fromSection: Int, toSection: Int)
    func collectionTableView(_ collectionTableView: LHCollectionTableView, canMoveItemAt indexPath: IndexPath) -> Bool
    func collectionTableView(_ collectionTableView: LHCollectionTableView, moveItemAt fromIndexPath: IndexPath, toIndexPath: IndexPath)
}

public extension LHCollectionTableViewDataSource {
    func numberOfSections(in collectionTableView: LHCollectionTableView) -> Int { return 1 }
    func collectionTableView(_ collectionTableView: LHCollectionTableView, canMoveSection section: Int) -> Bool { return false }
    func collectionTableView(_ collectionTableView: LHCollectionTableView, moveSection fromSection: Int, toSection: Int) { }
    func collectionTableView(_ collectionTableView: LHCollectionTableView, canMoveItemAt indexPath: IndexPath) -> Bool { return false }
    func collectionTableView(_ collectionTableView: LHCollectionTableView, moveItemAt fromIndexPath: IndexPath, toIndexPath: IndexPath) { }
}

public protocol LHCollectionTableViewDelegate: AnyObject {
    func collectionTableView(_ collectionTableView: LHCollectionTableView, canPerformAction action: Selector, forSection section: Int) -> Bool
    func collectionTableView(_ collectionTableView: LHCollectionTableView, performAction action: Selector, forSection section: Int)
    func collectionTableView(_ collectionTableView: LHCollectionTableView, canPerformAction action: Selector, forItemAt indexPath: IndexPath) -> Bool
    func collectionTableView(_ collectionTableView: LHCollectionTableView, performAction action: Selector, forItemAt indexPath: IndexPath)
}

public extension LHCollectionTableViewDelegate {
    func collectionTableView(_ collectionTableView: LHCollectionTableView, canPerformAction action: Selector, forSection section: Int) -> Bool { return false }
    func collectionTableView(_ collectionTableView: LHCollectionTableView, performAction action: Selector, forSection section: Int) { }
    func collectionTableView(_ collectionTableView: LHCollectionTableView, canPerformAction action: Selector, forItemAt indexPath: IndexPath) -> Bool { return false }
    func collectionTableView(_ collectionTableView: LHCollectionTableView, performAction action: Selector, forItemAt indexPath: IndexPath) { }
}

open class LHCollectionTableView: UIView {
    
    enum UserInterfaceStyle {
        case dark, light
    }
    
    var userInterfaceStyle: UserInterfaceStyle = .light

    @IBOutlet private weak var tableView: UITableView!
    private var cellContentOffsets: [IndexPath : CGPoint] = [:]
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
    
//    var userInterfaceStyle
    
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

// MARK: - UITableView

extension LHCollectionTableView: UITableViewDataSource {
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionCount = dataSource?.numberOfSections(in: self) ?? 0
        emptyStateView?.isHidden = sectionCount != 0
        return sectionCount
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Scene Cell", for: indexPath) as! LHCollectionTableViewSectionCell
        
        cell.dataSource = self
        cell.delegate = self
        DispatchQueue.main.async(execute: cell.reloadData)
        dataSource?.collectionTableView(self, configure: cell, forSection: indexPath.row)
        return cell
    }
    
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return dataSource?.collectionTableView(self, canMoveSection: indexPath.row) ?? false
    }
    
    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        dataSource?.collectionTableView(self, moveSection: sourceIndexPath.row, toSection: destinationIndexPath.row)
    }
}

extension LHCollectionTableView: UITableViewDelegate {
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? LHCollectionTableViewSectionCell, let offset = cellContentOffsets[indexPath] {
            cell.contentOffset = offset
        }
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? LHCollectionTableViewSectionCell {
            cellContentOffsets[indexPath] = cell.contentOffset
        }
    }
    
    open func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    open func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return delegate?.collectionTableView(self, canPerformAction: action, forSection: indexPath.row) ?? false
    }
    
    open func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        delegate?.collectionTableView(self, performAction: action, forSection: indexPath.row)
    }
    
}

extension LHCollectionTableView: UITableViewDragDelegate, UITableViewDropDelegate {

    open func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }

    open func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .cancel)
    }

    open func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }

}

// MARK: - LHCollectionTableViewSectionCell

extension LHCollectionTableView: StoryboardViewSectionCellDataSource {
    
    func numberOfItems(for sectionCell: LHCollectionTableViewSectionCell) -> Int {
        guard let section = self.section(for: sectionCell) else { return 0 }
        return dataSource?.collectionTableView(self, numberOfItemsInSection: section) ?? 0
    }
    
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, cellForItemAt indexPath: IndexPath) -> LHCollectionTableViewCell {
        let cell = sectionCell.dequeueReusableCell(withReuseIdentifier: "Shot Cell", for: indexPath)
        if let section = self.section(for: sectionCell) {
            dataSource?.collectionTableView(self, configure: cell, forItemAt: IndexPath(item: indexPath.item, section: section))
        }
        return cell
    }
    
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let section = self.section(for: sectionCell) else { return false }
        return dataSource?.collectionTableView(self, canMoveItemAt: IndexPath(item: indexPath.item, section: section)) ?? false
    }
    
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, moveItemAt fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        dataSource?.collectionTableView(self, moveItemAt: fromIndexPath, toIndexPath: toIndexPath)
        moveItem(at: fromIndexPath, to: toIndexPath)
    }
    
}

extension LHCollectionTableView: StoryboardViewSectionCellDelegate {
    
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, canPerformAction action: Selector, forItemAt indexPath: IndexPath) -> Bool {
        guard let section = self.section(for: sectionCell) else { return false }
        return delegate?.collectionTableView(self, canPerformAction: action, forItemAt: IndexPath(item: indexPath.item, section: section)) ?? false
    }
    
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, performAction action: Selector, forItemAt indexPath: IndexPath) {
        guard let section = self.section(for: sectionCell) else { return }
        delegate?.collectionTableView(self, performAction: action, forItemAt: IndexPath(item: indexPath.item, section: section))
    }
    
}
