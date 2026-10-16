import Foundation
import Observation

@Observable
final class ParseButtonLogic {
    private let logger = SessionLogger.shared
    var isLoading: Bool = false
    
    func startParsing(tableLogic: PlaylistTableLogic) {
        let url = GlobalState.shared.urlString
        logger.log("👆 ParseButtonLogic: запуск парсинга. Длина URL: \(url.count)")
        
        guard !url.isEmpty else {
            logger.log("⚠️ ParseButtonLogic отменен: пустая строка URL")
            return
        }
        isLoading = true
        
        Task {
            do {
                logger.log("⏳ ParseButtonLogic: вызов PlaylistParser.fetchPlaylist...")
                let fetchedTracks = try await PlaylistParser.fetchPlaylist(url: url)
                logger.log("✅ ParseButtonLogic: успешно распарсено элементов: \(fetchedTracks.count)")
                
                await MainActor.run {
                    tableLogic.tracks = fetchedTracks.map {
                        TrackItem(title: $0.title, duration: $0.duration, url: $0.url, isSelected: true)
                    }
                    GlobalState.shared.tracks = tableLogic.tracks
                    isLoading = false
                    logger.log("UI обновлен: треки переданы в таблицу и глобальное состояние, флаг загрузки снят")
                }
            } catch {
                logger.log("❌ ParseButtonLogic ошибка: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}


