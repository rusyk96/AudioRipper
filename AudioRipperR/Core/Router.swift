import SwiftUI

enum Router {
    private static let logger = SessionLogger.shared
    
    @ViewBuilder
    static func makeURLInput() -> some View {
        let _ = logger.log("🎨 UI Router: создание фабрики -> makeURLInput")
        URLInputBinding()
    }
    
    @ViewBuilder
    static func makeParseButton() -> some View {
        let _ = logger.log("🎨 UI Router: создание фабрики -> makeParseButton")
        ParseButtonBinding()
    }
    
    @ViewBuilder
    static func makeSettingsPanel() -> some View {
        let _ = logger.log("🎨 UI Router: создание фабрики -> makeSettingsPanel")
        SettingsPanelBinding()
    }
    
    @ViewBuilder
    static func makePlaylistTable() -> some View {
        let _ = logger.log("🎨 UI Router: создание фабрики -> makePlaylistTable")
        PlaylistTableBinding()
    }
    
    @ViewBuilder
    static func makeDownloadQueue() -> some View {
        let _ = logger.log("🎨 UI Router: создание фабрики -> makeDownloadQueue")
        DownloadQueueBinding()
    }
}
