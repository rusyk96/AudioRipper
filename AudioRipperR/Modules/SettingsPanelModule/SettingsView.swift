import SwiftUI

struct SettingsView: View {
    private static let logger = SessionLogger.shared
    @Bindable var logic: SettingsLogic
    
    var body: some View {
        let _ = Self.logger.log("🎨 UI View: рендеринг SettingsView (текущая папка: \(logic.folderName), формат: \(logic.selectedFormat))")
        
        return HStack(spacing: 12) {
            // Выбор папки
            Button(action: { logic.chooseFolder() }) {
                HStack(spacing: 6) {
                    Image(systemName: "folder")
                    Text(logic.folderName)
                }
            }
            .buttonStyle(.bordered)
            
            // Селектор формата
            Picker("", selection: $logic.selectedFormat) {
                Text("MP3").tag("mp3")
                Text("M4A").tag("m4a")
                Text("FLAC").tag("flac")
            }
            .pickerStyle(.segmented)
            .frame(width: 130)
        }
    }
}

