//
//  PlaylistParser.swift
//  AudioRipperR
//
//  Created by Руслан on 10/16/26.
//

import Foundation

struct ParsedTrack {
    let title: String
    let duration: String
    let url: String
}

final class PlaylistParser {
    private static let logger = SessionLogger.shared
    
    static func fetchPlaylist(url: String) async throws -> [ParsedTrack] {
        logger.log("🔍 PlaylistParser: поиск бинарника yt-dlp в бандле...")
        guard let ytDlpPath = Bundle.main.path(forResource: "yt-dlp", ofType: nil) else {
            logger.log("❌ PlaylistParser: КРИТИЧЕСКАЯ ОШИБКА — бинарник yt-dlp не найден в бандле")
            throw NSError(domain: "PlaylistParser", code: 404, userInfo: [NSLocalizedDescriptionKey: "Бинарник yt-dlp не найден в бандле приложения!"])
        }
        logger.log("📁 PlaylistParser: бинарник обнаружен по пути: \(ytDlpPath)")
        
        let arguments = ["--flat-playlist", "--dump-json", url]
        var tracks: [ParsedTrack] = []
        
        logger.log("⚙️ PlaylistParser: запуск YTProcessRunner для сканирования плейлиста")
        try await YTProcessRunner.run(executablePath: ytDlpPath, arguments: arguments) { output in
            let lines = output.components(separatedBy: .newlines)
            for line in lines {
                guard let data = line.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let title = json["title"] as? String else {
                    continue
                }
                
                let durationSec = json["duration"] as? Double ?? 0
                let durationStr = durationSec > 0 ? formatDuration(durationSec) : "--"
                let videoId = json["id"] as? String ?? ""
                let videoUrl = videoId.isEmpty ? url : "https://www.youtube.com/watch?v=\(videoId)"
                
                tracks.append(ParsedTrack(title: title, duration: durationStr, url: videoUrl))
            }
        }
        
        if tracks.isEmpty {
            logger.log("⚠️ PlaylistParser: парсер завершил работу, но треки через JSON не обнаружены")
        } else {
            logger.log("✅ PlaylistParser: успешно распарсено элементов: \(tracks.count)")
        }
        
        return tracks
    }
    
    private static func formatDuration(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}



