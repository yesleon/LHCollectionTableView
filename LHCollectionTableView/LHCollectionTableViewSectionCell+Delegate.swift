//
//  LHCollectionTableViewSectionCell+Delegate.swift
//  LHCollectionTableView
//
//  Created by 許立衡 on 2018/11/9.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import Foundation


protocol LHCollectionTableViewSectionCellDelegate: AnyObject {
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, canPerformAction action: Selector, forItemAt indexPath: IndexPath) -> Bool
    func sectionCell(_ sectionCell: LHCollectionTableViewSectionCell, performAction action: Selector, forItemAt indexPath: IndexPath)
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
