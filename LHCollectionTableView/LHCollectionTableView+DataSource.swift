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
        return sectionCount
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Scene Cell", for: indexPath) as! LHCollectionTableViewSectionCell
        
        cell.dataSource = self
        cell.delegate = self
        cell.dragDelegate = self
        cell.dropDelegate = self
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
    
}
