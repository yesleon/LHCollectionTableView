//
//  LHCollectionViewFlowLayout.swift
//  LHCollectionTableView
//
//  Created by 許立衡 on 2018/11/12.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit

class LHCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var delegate: UICollectionViewDelegateFlowLayout? {
        return collectionView?.delegate as? UICollectionViewDelegateFlowLayout
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        let layoutMargins = collectionView?.layoutMargins ?? .zero
        let contentInset = UIEdgeInsets(
            top: layoutMargins.top + sectionInset.top,
            left: layoutMargins.left + sectionInset.left,
            bottom: layoutMargins.bottom + sectionInset.bottom,
            right: layoutMargins.right + sectionInset.right)
        
        var origin = CGPoint(x: contentInset.left, y: contentInset.top)
        var maxX: CGFloat = -1.0
        var maxY: CGFloat = -1.0
        var newAttributes = [UICollectionViewLayoutAttributes]()
        attributes.forEach {
            let attribute = $0.copy() as! UICollectionViewLayoutAttributes
            
            switch scrollDirection {
            case .vertical:
                if attribute.frame.origin.y >= maxY {
                    origin.x = contentInset.left
                }
                attribute.frame.origin.x = origin.x
                origin.x += itemSize.width + minimumInteritemSpacing
                maxY = max(attribute.frame.maxY, maxY)
            case .horizontal:
                if attribute.frame.origin.x >= maxX {
                    origin.y = contentInset.top
                }
                attribute.frame.origin.y = origin.y
                origin.y += itemSize.height + minimumInteritemSpacing
                maxX = max(attribute.frame.maxX, maxX)
            }
            newAttributes.append(attribute)
        }
        
        return newAttributes
    }
}
