//
//  UpdateChecker.swift
//  AudioRipperR
//
//  Created by Руслан on 10/17/26.
//

import Foundation

struct AppVersionInfo: Codable {
    let latestVersion: String
    let updateUrl: String
    let changelog: String
    
    enum CodingKeys: String, CodingKey {
        case latestVersion = "latest_version"
        case updateUrl = "update_url"
        case changelog = "changelog"
    }
}

final class UpdateChecker {
    private static let logger = SessionLogger.shared
    
    // Прямая сырая ссылка на version.json в твоем репозитории на GitHub
    private static let versionURL = URL(string: "https://raw.githubusercontent.com/rusyk96/AudioRipper/main/AudioRipperR/version.json")!

    
    static func checkForUpdates() async -> AppVersionInfo? {
        logger.log("🔄 UpdateChecker: запуск проверки обновлений с GitHub...")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: versionURL)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                logger.log("⚠️ UpdateChecker: сервер вернул неверный код ответа при проверке обновлений")
                return nil
            }
            
            let decoder = JSONDecoder()
            let versionInfo = try decoder.decode(AppVersionInfo.self, from: data)
            
            logger.log("✅ UpdateChecker: успешно получена информация о версии с сервера: \(versionInfo.latestVersion)")
            
            // Сравниваем с текущей версией приложения из бандла
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
            
            if versionInfo.latestVersion != currentVersion {
                logger.log("✨ UpdateChecker: доступна новая версия (\(versionInfo.latestVersion)). Текущая: \(currentVersion)")
                return versionInfo
            } else {
                logger.log("✔️ UpdateChecker: у пользователя установлена самая свежая версия")
                return nil
            }
            
        } catch {
            logger.log("❌ UpdateChecker ошибка при проверке обновлений: \(error.localizedDescription)")
            return nil
        }
    }
}
