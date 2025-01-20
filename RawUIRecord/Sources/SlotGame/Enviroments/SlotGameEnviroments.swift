//
//  SlotGameEnviroments.swift
//  RawUIRecord
//
//  Created by Phu Pham on 17/1/25.
//

import SwiftUI

// MARK: - theme
struct GameLayoutPositionConfigValueKey: EnvironmentKey {
    public static let defaultValue: GameLayoutPositionConfigModel = .init(
        slotMachineRawSize: .zero,
        slotColumnRawSize: .zero,
        slotButtonControlSize: .zero,
        columnsConfigs: [],
        buttonsConfigs: [],
        playButtonConfig: .init(distanceFromLeftToParent: 0, distanceFromTopToParent: 0)
    )
}

struct GamePlayConfigValueKey: EnvironmentKey {
    public static let defaultValue: GamePlayConfigModel = .init()
}

public extension EnvironmentValues {
    internal var layoutPositionConfig: GameLayoutPositionConfigModel {
        get { self[GameLayoutPositionConfigValueKey.self] }
        set { self[GameLayoutPositionConfigValueKey.self] = newValue }
    }
    
    internal var gamePlayConfig: GamePlayConfigModel {
        get { self[GamePlayConfigValueKey.self] }
        set { self[GamePlayConfigValueKey.self] = newValue }
    }
}
