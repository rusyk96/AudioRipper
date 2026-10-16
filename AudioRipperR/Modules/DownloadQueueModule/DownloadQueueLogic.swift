import Foundation
import Observation

@Observable
final class DownloadQueueLogic {
    private let logger = SessionLogger.shared
    
    var isDownloading: Bool {
        get { GlobalState.shared.isDownloading }
        set {
            GlobalState.shared.isDownloading = newValue
            logger.log("🔄 DownloadQueueLogic: статус загрузки изменен на isDownloading = \(newValue)")
        }
    }
    
    var progress: Double {
        get { GlobalState.shared.downloadProgress }
        set { GlobalState.shared.downloadProgress = newValue }
    }
    
    func startDownload() {
        logger.log("👆 DownloadQueueLogic: пользователь нажал кнопку 'Скачать выбранное'")
        GlobalState.shared.downloadSelectedTracks()
    }
}
