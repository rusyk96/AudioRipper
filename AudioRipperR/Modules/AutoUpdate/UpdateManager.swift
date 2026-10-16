//
//  UpdateManager.swift
//  AudioRipperR
//
//  Created by Руслан on 10/17/26.
//

import Foundation

@Observable
final class UpdateManager {
    static let shared = UpdateManager()
    
    var showUpdateAlert = false
    var isDownloading = false
    var downloadProgress: Double = 0.0
    var statusMessage: String = ""
    var updateInfo: AppVersionInfo?
    
    private let downloader = UpdateDownloader()
    
    @MainActor
    func checkForUpdates() async {
        statusMessage = "Проверка обновлений..."
        if let info = await UpdateChecker.checkForUpdates() {
            self.updateInfo = info
            self.showUpdateAlert = true
            self.statusMessage = "Доступна версия \(info.latestVersion)"
        } else {
            self.statusMessage = "У вас установлена последняя версия"
        }
    }
    
    @MainActor
    func startUpdate() async {
        guard let info = updateInfo else { return }
        
        isDownloading = true
        statusMessage = "Скачивание обновления..."
        
        downloader.onProgressUpdate = { [weak self] progress in
            let percentage = Int(progress * 100)
            self?.downloadProgress = progress
            self?.statusMessage = "Загрузка: \(percentage)%"
        }
        
        do {
            let zipURL = try await downloader.download(from: info.updateUrl)
            statusMessage = "Распаковка и установка..."
            UpdateInstaller.applyUpdate(zipPath: zipURL)
        } catch {
            isDownloading = false
            statusMessage = "Ошибка загрузки: \(error.localizedDescription)"
        }
    }
}

    
