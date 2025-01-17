//
//  SlotMachineViewModel.swift
//  RawUIRecord
//
//  Created by Phu Pham on 16/1/25.
//

import SwiftUI
import Combine

struct SlotMachineWinningState {
    var isWinning: Bool = false
    var firstSelectedIndex: Int?
    
    var isInWinMode: Bool {
        isWinning && firstSelectedIndex != nil
    }
}

class SlotMachineViewModel: ObservableObject {
    // An array to hold references to each column's scrolling state
    var references: [ContinuousInfiniteReference<ContinuousInfiniteCollectionView>] = [
        ContinuousInfiniteReference<ContinuousInfiniteCollectionView>(),
        ContinuousInfiniteReference<ContinuousInfiniteCollectionView>(),
        ContinuousInfiniteReference<ContinuousInfiniteCollectionView>()
    ]
    
    private var referencesIsSpining: [ContinuousInfiniteReference<ContinuousInfiniteCollectionView>] {
        references.filter { reference in
            return reference.object?.isRolling ?? false
        }
    }
    
    var musicPlayer: [EMusicPlayers: PlaySoundHelper] = [
//        .backgroundSound: PlaySoundHelper(soundName: EMusicPlayers.backgroundSound.rawValue, isLoop: true, volume: 0.3),
        .gameOverSound: PlaySoundHelper(soundName: EMusicPlayers.gameOverSound.rawValue),
        .spinSound: PlaySoundHelper(soundName: EMusicPlayers.spinSound.rawValue),
        .winSound: PlaySoundHelper(soundName: EMusicPlayers.winSound.rawValue)
    ]
    
    @Published var spiningState: ESlotMachineState = .unset
    
    var winningState: SlotMachineWinningState = .init()
    
    private func setWinningIndex(_ index: Int?) {
        if self.winningState.firstSelectedIndex == index { return }
        
        self.winningState.firstSelectedIndex = index
    }
    
    private func setSpiningState(_ state: ESlotMachineState) {
        if self.spiningState == state { return }
        
        self.spiningState = state
    }
}

// callback function
extension SlotMachineViewModel {
    func onScrollStopedAt(_ index: Int?) {
        print("Run to onScrollStopedAt", winningState, index)
        
        if winningState.firstSelectedIndex != nil {
            return
        }
        
        self.setWinningIndex(index)
        
        self.setWinningStateForAllChild(winningState)
    }
    
    private func setWinningStateForAllChild(_ winningState: SlotMachineWinningState) {
        references.forEach { reference in
            reference.object?.setWinningState(winningState)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak reference] in
                reference?.object?.startAutomaticScroll()
            }
        }
    }
    
    // Stop scrolling all columns
    func stopAllScrolling() {
        for (index, reference) in referencesIsSpining.enumerated() {
            let delay = Double(index) * 0.2  // 0.2s delay for each additional column
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak reference] in
                reference?.object?.stopScrollImmediately()
                
                self?.setFinishedGameIfFinishAll()
            }
        }
    }
    
    func stopScrollingForElement(at index: Int) {
        references[index].object?.stopScrollImmediately()
        
        setFinishedGameIfFinishAll()
    }
    
    func clickSpinButton() {
        musicPlayer[.spinSound]?.playSound()
        
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
        setWinningIndex(nil)
        
        setWinningStateForAllChild(winningState)
        
        if winningState.isWinning {
            musicPlayer[.winSound]?.playSound()
        } else {
            musicPlayer[.gameOverSound]?.playSound()
        }
    }
}
