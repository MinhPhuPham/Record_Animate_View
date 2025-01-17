//
//  ContinuousInfiniteCollectionView+Cell.swift
//  RawUIRecord
//
//  Created by Phu Pham on 16/1/25.
//

import UIKit

class ContiniousInfiniteCollectionViewCell: UICollectionViewCell {
    static let identifier = "ContiniousInfiniteCollectionViewCell"
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Center the imageView in the cell
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    func configure(with model: ContinuousInfiniteModel){
        imageView.image = UIImage(named: model.imageName)
        imageView.backgroundColor = model.backgroundColor
        
        NSLayoutConstraint.activate([
            // Set the width and height to be 80% of the cell's width and height
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: model.imageScaleRatioWithParent),
            imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: model.imageScaleRatioWithParent)
        ])
    }
}
