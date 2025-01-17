//
//  SlotGameViewModel.swift
//  RawUIRecord
//
//  Created by Phu Pham on 16/1/25.
//

import SwiftUI
import Combine

struct SlotGameWinningState {
    var isWinning: Bool = false
    var firstSelectedIndex: Int?
    
    var isInWinMode: Bool {
        isWinning && firstSelectedIndex != nil
    }
}

class SlotGameViewModel: ObservableObject {
    var configure: GamePlayConfigModel
    
    init(configure: GamePlayConfigModel) {
        self.configure = configure
    }
    
    // An array to hold references to each column's scrolling state
    var references: [ContinuousInfiniteReference<SlotMachineAutoScrollView>] = [
        ContinuousInfiniteReference<SlotMachineAutoScrollView>(),
        ContinuousInfiniteReference<SlotMachineAutoScrollView>(),
        ContinuousInfiniteReference<SlotMachineAutoScrollView>()
    ]
    
    private var referencesIsSpining: [ContinuousInfiniteReference<SlotMachineAutoScrollView>] {
        references.filter { reference in
            return reference.object?.isRolling ?? false
        }
    }
    
    var musicPlayer: [EMusicPlayers: PlaySoundHelper] = [
        .backgroundSound: PlaySoundHelper(soundName: EMusicPlayers.backgroundSound.rawValue, isLoop: true, volume: 0.3, isBigFile: true),
        .gameOverSound: PlaySoundHelper(soundName: EMusicPlayers.gameOverSound.rawValue),
        .spinSound: PlaySoundHelper(soundName: EMusicPlayers.spinSound.rawValue),
        .winSound: PlaySoundHelper(soundName: EMusicPlayers.winSound.rawValue)
    ]
    
    @Published var spiningState: ESlotMachineState = .unset
    
    var winningState: SlotGameWinningState = .init()
    
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
extension SlotGameViewModel {
    func onScrollStopedAt(_ index: Int?) {
        guard winningState.firstSelectedIndex == nil else { return }
        
        print("Run to onScrollStopedAt parent: \(index ?? -1)")
        
        setWinningIndex(index)
        setWinningStateForAllChild(winningState)
    }
    
    private func setWinningStateForAllChild(_ winningState: SlotGameWinningState) {
        references.forEach { reference in
            reference.object?.setWinningState(winningState)
        }
    }
}

// Action functions
extension SlotGameViewModel {
    // Start scrolling all columns
    func startScrolling() {
        setSpiningState(.playingStarting)
        
        for (index, reference) in references.enumerated() {
            let delay = Double(index) * configure.delayBetweenStartAll
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak ref = reference] in
                ref?.object?.startAutomaticScroll()
                
                self?.checkStartedSpningForAll()
            }
        }
    }
    
    // Stop scrolling all columns
    func stopAllScrolling() {
        setSpiningState(.playingEnding)
        
        for (index, reference) in referencesIsSpining.enumerated() {
            let delay = Double(index) * configure.delayBetweenStopAll
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak ref = reference] in
                ref?.object?.stopScrollImmediately()
                
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
        case .unset, .played:
            startScrolling()
        case .playing:
            stopAllScrolling()
        case .playingEnding, .playingStarting:
            break
        }
    }
    
    private func checkStartedSpningForAll() {
        if referencesIsSpining.count == references.count {
            setSpiningState(.playing)
        }
    }
    
    private func setFinishedGameIfFinishAll() {
        if referencesIsSpining.isEmpty {
            setFinishGameActions()
        }
    }
    
    private func setFinishGameActions() {
        setWinningIndex(nil)
        setSpiningState(.played)
        
        if winningState.isWinning {
            musicPlayer[.winSound]?.playSound()
        } else {
            musicPlayer[.gameOverSound]?.playSound()
        }
    }
}
