//
//  SlotMachineFlowLayout.swift
//  RawUIRecord
//
//  Created by Phu Pham on 20/1/25.
//

import UIKit

public class SlotMachineFlowLayout: UICollectionViewFlowLayout {
    
    open var maxAngle : CGFloat = CGFloat.pi / 2
    open var isFlat : Bool = true
    
    fileprivate var _halfDim : CGFloat {
        get {
            return _visibleRect.height
        }
    }
    fileprivate var _mid : CGFloat {
        get {
            return _visibleRect.midY
        }
    }
    fileprivate var _visibleRect : CGRect {
        get {
            if let cv = collectionView {
                return CGRect(origin: cv.contentOffset, size: cv.bounds.size)
            }
            return CGRect.zero
        }
    }
    
    func initialize() {
        sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        minimumLineSpacing = 0.0
    }
    
    override init() {
        super.init()
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes {
            if isFlat == false {
                let distance = attributes.frame.midY - _mid
                let currentAngle = maxAngle * distance / _halfDim / (CGFloat.pi / 2)
                var transform = CATransform3DIdentity

                transform = CATransform3DTranslate(transform, 0, distance, -_halfDim)
                transform = CATransform3DRotate(transform, currentAngle, 1, 0, 0)
                
                transform = CATransform3DTranslate(transform, 0, 0, _halfDim)
                attributes.transform3D = transform
                attributes.alpha = abs(currentAngle) < maxAngle ? 1.0 : 0.0
                return attributes;
            }
            return attributes
        }
        
        return nil
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if isFlat == false {
            var attributes = [UICollectionViewLayoutAttributes]()
            if self.collectionView!.numberOfSections > 0 {
                for i in 0 ..< self.collectionView!.numberOfItems(inSection: 0) {
                    let indexPath = IndexPath(item: i, section: 0)
                    attributes.append(self.layoutAttributesForItem(at: indexPath)!)
                }
            }
            return attributes
        }
        return super.layoutAttributesForElements(in: rect)
    }
    
    var snapToCenter : Bool = true
    
    var mostRecentOffset : CGPoint = CGPoint()
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // fallback
        mostRecentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        return mostRecentOffset
    }
}
