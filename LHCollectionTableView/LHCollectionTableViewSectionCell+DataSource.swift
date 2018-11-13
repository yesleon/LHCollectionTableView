//
//  LHCollectionTableViewSectionCell+DataSource.swift
//  LHCollectionTableView
//
//  Created by 許立衡 on 2018/11/9.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import Foundation

extension LHCollectionTableViewSectionCell: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemCount = numberOfItems()
        emptyStateView?.isHidden = itemCount != 0
        return itemCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Shot Cell", for: indexPath) as! LHCollectionTableViewCell
        configureCellAtIndexPath(cell, indexPath)
        return cell
    }
    
}
