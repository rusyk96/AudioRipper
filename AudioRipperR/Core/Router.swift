import SwiftUI

enum Router {
    @ViewBuilder
    static func makeURLInput() -> some View {
        URLInputBinding()
    }
    
    @ViewBuilder
    static func makeParseButton() -> some View {
        ParseButtonBinding()
    }
    
    @ViewBuilder
    static func makeSettingsPanel() -> some View {
        SettingsPanelBinding()
    }
    
    @ViewBuilder
    static func makePlaylistTable() -> some View {
        PlaylistTableBinding()
    }
    
    @ViewBuilder
    static func makeDownloadQueue() -> some View {
        DownloadQueueBinding()
    }
}
