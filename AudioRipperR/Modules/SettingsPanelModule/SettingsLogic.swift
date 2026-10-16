import Foundation
import AppKit
import Observation

@Observable
final class SettingsLogic {
    private let logger = SessionLogger.shared
    
    var selectedFormat: String = "mp3" {
        didSet {
            GlobalState.shared.selectedAudioFormat = selectedFormat
            logger.log("⚙️ SettingsLogic: аудиоформат изменен на '\(selectedFormat)'")
        }
    }
    
    var folderName: String = "Музыка"
    
    func chooseFolder() {
        logger.log("📂 SettingsLogic: открытие системной панели выбора папки (NSOpenPanel)")
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Выбрать"
        
        if panel.runModal() == .OK, let url = panel.url {
            GlobalState.shared.outputDirectory = url
            folderName = url.lastPathComponent
            logger.log("✅ SettingsLogic: новая папка для сохранения успешно выбрана: \(url.path)")
        } else {
            logger.log("⚠️ SettingsLogic: выбор папки отменен пользователем")
        }
    }
}
