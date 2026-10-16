import SwiftUI

struct SettingsPanelBinding: View {
    private static let logger = SessionLogger.shared
    @State private var logic = SettingsLogic()
    
    var body: some View {
        let _ = Self.logger.log("🧩 UI Binding: инициализация SettingsPanelBinding")
        return SettingsView(logic: logic)
    }
}

