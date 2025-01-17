//
//  SlotMachineAutoScrollView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 16/1/25.
//

import UIKit

class SlotMachineAutoScrollView: UIViewController {

    var models: [SlotMachineItemModel]

    // Additional variables
    var configure: SlotMachineCongfigure = .init()
    
    var itemHeight: CGFloat {
        print("collectionView.frame", collectionView.frame.size)
        return collectionView.frame.height / CGFloat(configure.visibleItemsCount)
    }
    
    // Winning item if need
    var winningState: SlotGameWinningState = .init()
    
    var onScrollStopedAt: ((Int) -> Void)?
    
    private var totalElements: Int = 0
    private var displayLink: CADisplayLink?
    var isRolling: Bool = true
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            ContiniousInfiniteCollectionViewCell.self,
            forCellWithReuseIdentifier: ContiniousInfiniteCollectionViewCell.identifier
        )
    
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isUserInteractionEnabled = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    // Custom initializer to set configs
    init(models: [SlotMachineItemModel], configure: SlotMachineCongfigure) {
        self.models = models
        self.configure = configure
        
        super.init(nibName: nil, bundle: nil)
    }
    
    // Required initializer if using storyboards, which isn't recommended for UIViewControllers without nibs
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    deinit {
        stopAutomaticScroll()
    }
}

// Automatic scroll using CADisplayLink
extension SlotMachineAutoScrollView {
    func startAutomaticScroll() {
        isRolling = true
        
        displayLink = CADisplayLink(target: self, selector: #selector(handleScroll))
        displayLink?.add(to: .main, forMode: .default)
        displayLink?.preferredFramesPerSecond = 60
    }
    
    func stopScrollImmediately() {
        if !isRolling { return }
        
        onStopedScroll()
        
        isRolling = false
        
        stopAutomaticScroll()
    }

    @objc private func handleScroll() {
        guard isRolling else { return }

        // Update content offset for downward scrolling
        collectionView.contentOffset.y -= configure.scrollSpeed
    }
    
    private func stopAutomaticScroll() {
        displayLink?.isPaused = true
        displayLink = nil
    }
}

// Handle on stop logic
extension SlotMachineAutoScrollView {
    func setWinningState(_ state: SlotGameWinningState) {
        self.winningState = state
    }
    
    private func onStopedScroll() {
        let midContentOffset = collectionView.bounds.midY + collectionView.contentOffset.y
        let centerIndex = Int(midContentOffset / itemHeight) % models.count
        
        let indexToScroll: Int
        if winningState.isWinning, let winningIndex = winningState.firstSelectedIndex {
            indexToScroll = winningIndex
        } else {
            indexToScroll = centerIndex
        }

        let isNotWinningAndSameIndex = !winningState.isWinning && indexToScroll == centerIndex
        let adjustedIndex = isNotWinningAndSameIndex ? centerIndex + 1 : indexToScroll
        
        print("onScrollStopedAt adjustedIndex", adjustedIndex)
        
        onScrollStopedAt?(adjustedIndex)
        scrollToItem(at: adjustedIndex)
    }
    
    private func scrollToItem(at index: Int) {
        
        // Calculate the desired content offset for centering the item
        let newOffsetY = CGFloat(index) * itemHeight
        
         print("Scrolling to index: \(index), offset: \(newOffsetY) winningState \(winningState)")
        
        self.collectionView.contentOffset.y = newOffsetY
        
//        self.collectionView.layer.removeAllAnimations()
//        
//        // Using animation block or no animation according to requirement
//        UIView.animate(withDuration: 0.1) {
//            self.collectionView.contentOffset.y = newOffsetY
//        }
    }
}

extension SlotMachineAutoScrollView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalElements = configure.buffer + models.count
        return totalElements
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ContiniousInfiniteCollectionViewCell.identifier,
            for: indexPath
        ) as? ContiniousInfiniteCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        let currentCell = indexPath.row % models.count
        cell.configure(with: models[currentCell])
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        
        return CGSize(width: width, height: itemHeight)
    }
}

extension SlotMachineAutoScrollView: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let totalHeight = itemHeight * CGFloat(models.count)

        // When scrolling beyond the total height, reset it by subtracting the total height
        if scrollView.contentOffset.y > totalHeight {
            collectionView.contentOffset.y -= totalHeight
        }
        
        // When scrolling above zero, reset it by adding the total height
        if scrollView.contentOffset.y < 0 {
            collectionView.contentOffset.y += totalHeight
        }
    }
}

