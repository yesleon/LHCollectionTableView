//
//  LHCollectionTableViewSectionCell+DataSource.swift
//  LHCollectionTableView
//
//  Created by 許立衡 on 2018/11/9.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import Foundation


protocol StoryboardViewSectionCellDataSource: AnyObject {
//    func numberOfItems(for sectionCell: LHCollectionTableViewSectionCell) -> Int
//    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, cellForItemAt indexPath: IndexPath) -> LHCollectionTableViewCell
}


extension LHCollectionTableViewSectionCell: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let itemCount = dataSource?.numberOfItems(for: self) ?? 0
        let itemCount = numberOfItems()
        emptyStateView?.isHidden = itemCount != 0
        return itemCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Shot Cell", for: indexPath) as! LHCollectionTableViewCell
        configureCellAtIndexPath(cell, indexPath)
//        return dataSource!.sectionCell(self, cellForItemAt: indexPath)
        return cell
    }
    
}
