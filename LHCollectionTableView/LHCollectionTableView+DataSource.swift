//
//  LHCollectionTableView+DataSource.swift
//  LHCollectionTableView
//
//  Created by 許立衡 on 2018/11/9.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import Foundation



public protocol LHCollectionTableViewDataSource: AnyObject {
    func numberOfSections(in collectionTableView: LHCollectionTableView) -> Int
    func collectionTableView(_ collectionTableView: LHCollectionTableView, numberOfItemsInSection section: Int) -> Int
    func collectionTableView(_ collectionTableView: LHCollectionTableView, configure cell: LHCollectionTableViewCell, forItemAt indexPath: IndexPath)
    func collectionTableView(_ collectionTableView: LHCollectionTableView, configure sectionCell: LHCollectionTableViewSectionCell, forSection section: Int)
    func collectionTableView(_ collectionTableView: LHCollectionTableView, canMoveSection section: Int) -> Bool
    func collectionTableView(_ collectionTableView: LHCollectionTableView, moveSection fromSection: Int, toSection: Int)
}

public extension LHCollectionTableViewDataSource {
    func numberOfSections(in collectionTableView: LHCollectionTableView) -> Int { return 1 }
    func collectionTableView(_ collectionTableView: LHCollectionTableView, canMoveSection section: Int) -> Bool { return false }
    func collectionTableView(_ collectionTableView: LHCollectionTableView, moveSection fromSection: Int, toSection: Int) { }
}


extension LHCollectionTableView: UITableViewDataSource {
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionCount = dataSource?.numberOfSections(in: self) ?? 0
        emptyStateView?.isHidden = sectionCount != 0
        while cellIDs.count < sectionCount {
            cellIDs.append(UUID().uuidString)
        }
        return sectionCount
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Scene Cell", for: indexPath) as! LHCollectionTableViewSectionCell
        
        cell.delegate = self
        cell.dragDelegate = self
        cell.dropDelegate = self
        weak var weakCell = cell
        cell.numberOfItems = { [weak self] in
            guard let weakSelf = self else { return 0 }
            guard let cell = weakCell else { return 0 }
            let section = weakSelf.section(for: cell) ?? indexPath.row
            return weakSelf.dataSource?.collectionTableView(weakSelf, numberOfItemsInSection: section) ?? 0
        }
        cell.configureCellAtIndexPath = { [weak self] in
            guard let weakSelf = self else { return }
            guard let cell = weakCell else { return }
            let section = weakSelf.section(for: cell) ?? indexPath.row
            weakSelf.dataSource?.collectionTableView(weakSelf, configure: $0, forItemAt: IndexPath(item: $1.item, section: section))
        }
        cell.reloadData()
        if cell.id.isEmpty {
            cell.id = cellIDs[indexPath.row]
        }
        if let collapsed = cellIsCollapsed[cell.id], cell.isCollapsed != collapsed {
            cell.isCollapsed = collapsed
        }
        if let offset = cellContentOffsets[cell.id] {
            cell.contentOffset = offset
        }
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
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
