//
//  LHCollectionView.swift
//  StoryboardsStoryboardScene
//
//  Created by 許立衡 on 2018/11/11.
//  Copyright © 2018 narrativesaw. All rights reserved.
//

import UIKit

@IBDesignable
class LHCollectionView: UICollectionView {

    override var intrinsicContentSize: CGSize {
        if isScrollEnabled {
            if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
                return CGSize(width: UIView.noIntrinsicMetric, height: layout.itemSize.height + layout.sectionInset.top + layout.sectionInset.bottom)
            } else {
                return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
            }
        } else {
            return collectionViewLayout.collectionViewContentSize
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }

}
