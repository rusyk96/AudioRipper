import Foundation
import Observation

@Observable
final class GlobalState {
    static let shared = GlobalState()
    
    var outputDirectory: URL = FileManager.default.urls(for: .musicDirectory, in: .userDomainMask).first!
    var selectedAudioFormat: String = "mp3" // "mp3", "m4a", "flac"
    var urlString: String = ""
    var tracks: [TrackItem] = []
    var isParsing: Bool = false
    var isDownloading: Bool = false
    var downloadProgress: Double = 0.0
    
    private let logger = SessionLogger.shared // Наш будущий модуль логирования
    
    var isValidUrl: Bool {
        let valid = urlString.contains("youtube.com") || urlString.contains("youtu.be")
        if !valid && !urlString.isEmpty {
            logger.log("⚠️ Проверка URL: введен некорректный формат ссылки")
        }
        return valid
    }
    
    private init() {
        logger.startNewSession()
        logger.log("🚀 Инициализация GlobalState. Путь выгрузки: \(outputDirectory.path)")
    }
    
    func parsePlaylist() {
        logger.log("🟢 Запуск parsePlaylist. Длина URL-строки: \(urlString.count)")
        guard isValidUrl else {
            logger.log("❌ Ошибка парсинга: невалидный URL")
            return
        }
        isParsing = true
        
        Task {
            do {
                logger.log("⏳ Начало сетевого запроса/парсинга плейлиста...")
                let fetchedTracks = try await PlaylistParser.fetchPlaylist(url: urlString)
                logger.log("✅ Успешно получено треков из источника: \(fetchedTracks.count)")
                
                await MainActor.run {
                    self.tracks = fetchedTracks.map {
                        TrackItem(title: $0.title, duration: $0.duration, url: $0.url, isSelected: true)
                    }
                    self.isParsing = false
                    logger.log("UI обновлен: список треков сформирован, парсинг завершен")
                }
            } catch {
                logger.log("❌ Ошибка при парсинге плейлиста: \(error.localizedDescription)")
                await MainActor.run {
                    self.isParsing = false
                }
            }
        }
    }
    
    func downloadSelectedTracks() {
        let selectedTracks = tracks.filter { $0.isSelected }
        logger.log("📥 Запрос на скачивание. Выбрано треков: \(selectedTracks.count) из \(tracks.count). Формат: \(selectedAudioFormat)")
        guard !selectedTracks.isEmpty else {
            logger.log("⚠️ Отмена скачивания: нет выбранных элементов")
            return
        }
        
        isDownloading = true
        downloadProgress = 0.0
        
        Task {
            guard let ytDlpPath = Bundle.main.path(forResource: "yt-dlp", ofType: nil),
                  let resourcesPath = Bundle.main.resourcePath else {
                logger.log("❌ Критическая ошибка: бинарник yt-dlp или ресурсы не найдены в бандле")
                await MainActor.run { self.isDownloading = false }
                return
            }
            
            logger.log("🔧 Бинарник yt-dlp обнаружен. Путь к ffmpeg: \(resourcesPath)")
            let total = Double(selectedTracks.count)
            
            for (index, track) in selectedTracks.enumerated() {
                let outputTemplate = outputDirectory.appendingPathComponent("%(title)s.%(ext)s").path
                let arguments = [
                    "-x",
                    "--audio-format", selectedAudioFormat,
                    "--ffmpeg-location", resourcesPath,
                    "-o", outputTemplate,
                    track.url
                ]
                
                logger.log("⚙️ Запуск процесса для элемента [\(index + 1)/\(Int(total))]")
                
                do {
                    try await YTProcessRunner.run(executablePath: ytDlpPath, arguments: arguments) { _ in }
                    logger.log("✔ Элемент [\(index + 1)] успешно обработан процессом")
                } catch {
                    logger.log("❌ Ошибка выполнения процесса для элемента [\(index + 1)]: \(error)")
                }
                
                let progressValue = Double(index + 1) / total
                await MainActor.run {
                    self.downloadProgress = progressValue
                }
            }
            
            await MainActor.run {
                self.isDownloading = false
                logger.log("🎉 Сессия скачивания успешно завершена. Все задачи выполнены.")
            }
        }
    }
}



