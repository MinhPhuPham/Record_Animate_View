//
//  SlotMachineViewModel.swift
//  RawUIRecord
//
//  Created by Phu Pham on 16/1/25.
//

import SwiftUI
import Combine

class SlotMachineViewModel: ObservableObject {
    enum ESlotMachineState {
        case unset
        case spining
        case played
        
        var isSpining: Bool {
            self == .spining
        }
    }
    
    static let data: [ContinuousInfiniteModel] = [
        ContinuousInfiniteModel(imageName: "apple"),
        ContinuousInfiniteModel(imageName: "bell"),
        ContinuousInfiniteModel(imageName: "cherry"),
        ContinuousInfiniteModel(imageName: "clover"),
        ContinuousInfiniteModel(imageName: "diamond"),
        ContinuousInfiniteModel(imageName: "grape"),
        ContinuousInfiniteModel(imageName: "lemon")
    ]
    
    // An array to hold references to each column's scrolling state
    var references: [ContinuousInfiniteReference<ContinuousInfiniteCollectionView>] = [
        ContinuousInfiniteReference<ContinuousInfiniteCollectionView>(),
        ContinuousInfiniteReference<ContinuousInfiniteCollectionView>(),
        ContinuousInfiniteReference<ContinuousInfiniteCollectionView>()
    ]
    
    private var referencesIsSpining: [ContinuousInfiniteReference<ContinuousInfiniteCollectionView>] {
        references.filter { reference in
            // Check if the object is not nil and not rolling
            if let object = reference.object {
                return object.isRolling
            }
            return false
        }
    }
    
    @Published var spiningState: ESlotMachineState = .unset
    
    @Published var isWinning: Bool = false
    
    private var currentWinningIndex: Int?
    
    private func setWinningIndex(_ index: Int?) {
        self.currentWinningIndex = index
    }
    
    private func setSpiningState(_ state: ESlotMachineState) {
        if self.spiningState == state { return }
        
        self.spiningState = state
    }
}

// callback function
extension SlotMachineViewModel {
    func onScrollStopedAt(_ index: Int?) {
        print("Run to onScrollStopedAt", currentWinningIndex, index, isWinning)
        
        if !isWinning {
            return
        }
        // Break if check currentWinningIndex has value or isWinning is false
        if let _ = currentWinningIndex {
            return
        }
        
        print("Run to here", index, isWinning)
        
        self.setWinningIndex(index)
        
        self.setWinningIndexForAllChild(index)
    }
    
    private func setWinningIndexForAllChild(_ index: Int?) {
        references.forEach { reference in
            reference.object?.setWinningIndex(index)
        }
    }
}

// Action functions
extension SlotMachineViewModel {
    // Start scrolling all columns
    func startScrolling() {
        setSpiningState(.spining)
        
        for (index, reference) in references.enumerated() {
            let delay = Double(index) * 0.2  // 0.2s delay for each additional column
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                reference.object?.startAutomaticScroll()
            }
        }
    }
    
    // Stop scrolling all columns
    func stopAllScrolling() {
        for (index, reference) in referencesIsSpining.enumerated() {
            let delay = Double(index) * 0.2  // 0.2s delay for each additional column
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                reference.object?.stopAutomaticScroll()
                
                self?.setFinishedGameIfFinishAll()
            }
        }
    }
    
    func stopScrollingForElement(at index: Int) {
        references[index].object?.stopAutomaticScroll()
        
        setFinishedGameIfFinishAll()
    }
    
    func clickSpinButton() {
//        PlaySouldHelper().playSound(sound: "spin")
        
        switch spiningState {
        case .unset:
            startScrolling()
        case .spining:
            stopAllScrolling()
        case .played:
            startScrolling()
        }
    }
    
    private func setFinishedGameIfFinishAll() {
        if referencesIsSpining.isEmpty {
            setFinishGameActions()
        }
    }
    
    private func setFinishGameActions() {
        print("Run to setFinishGameActions")
        setSpiningState(.played)
        
        setWinningIndexForAllChild(nil)
//        DispatchQueue.main.async {
//            let soundStateName = self.isWinning ? "win" : "game-over"
//            PlaySouldHelper().playSound(sound: soundStateName)
//        }
    }
}
