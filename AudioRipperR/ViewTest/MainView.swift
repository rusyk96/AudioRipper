import SwiftUI

struct MainView: View {
    private static let logger = SessionLogger.shared
    
    var body: some View {
        let _ = Self.logger.log("🖼️ UI View: рендеринг корневого экрана MainView")
        
        return VStack(spacing: 20) {
            // Верхняя часть: ввод ссылки и настройки
            HStack(spacing: 12) {
                Router.makeURLInput()
                Router.makeSettingsPanel()
            }
            
            // Кнопка парсинга плейлиста
            Router.makeParseButton()
            
            // Таблица треков
            Router.makePlaylistTable()
            
            // Нижняя панель очереди загрузки
            Router.makeDownloadQueue()
        }
        .padding(24)
    }
}
