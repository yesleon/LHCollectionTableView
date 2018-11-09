//
//  LHCollectionTableView+Delegate.swift
//  LHCollectionTableView
//
//  Created by 許立衡 on 2018/11/9.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import Foundation


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


// MARK: - UITableView

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
