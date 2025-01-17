//
//  SlotGameEnviroments.swift
//  RawUIRecord
//
//  Created by Phu Pham on 17/1/25.
//

import SwiftUI

// MARK: - theme
struct GameLayoutPositionConfigValueKey: EnvironmentKey {
    public static let defaultValue: GameLayoutPositionConfigModel = .init(slotMachineRawSize: .zero, columnsConfigs: [])
}

public extension EnvironmentValues {
    internal var layoutPositionConfig: GameLayoutPositionConfigModel {
        get { self[GameLayoutPositionConfigValueKey.self] }
        set { self[GameLayoutPositionConfigValueKey.self] = newValue }
    }
}
