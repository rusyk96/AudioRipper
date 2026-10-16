//
//  UpdateInstaller.swift
//  AudioRipperR
//
//  Created by Руслан on 10/17/26.
//

import Foundation
import AppKit

final class UpdateInstaller {
    private static let logger = SessionLogger.shared
    
    static func applyUpdate(zipPath: URL) {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent("AudioRipperR_Unzipped")
        
        do {
            // 1. Очищаем и создаем временную папку для распаковки
            if fileManager.fileExists(atPath: tempDir.path) {
                try fileManager.removeItem(at: tempDir)
            }
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
            
            // 2. Распаковываем архив с помощью встроенной системной утилиты unzip
            logger.log("📦 UpdateInstaller: распаковка архива обновлений...")
            let unzipProcess = Process()
            unzipProcess.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
            unzipProcess.arguments = [zipPath.path, "-d", tempDir.path]
            try unzipProcess.run()
            unzipProcess.waitUntilExit()
            
            // Ищем внутри распакованного каталога свежий .app бандл
            let contents = try fileManager.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            guard let newAppURL = contents.first(where: { $0.pathExtension == "app" }) else {
                logger.log("❌ UpdateInstaller: в архиве не найден .app файл")
                return
            }
            
            // 3. Определяем текущий путь программы
            let currentAppURL = Bundle.main.bundleURL
            let parentDir = currentAppURL.deletingLastPathComponent()
            
            logger.log("🔄 UpdateInstaller: подготовка к атомарной подмене бандла...")
            
            // 4. Создаем микро-скрипт подмены и перезапуска
            let scriptPath = tempDir.appendingPathComponent("updater.sh")
            let scriptContent = """
            #!/bin/bash
            sleep 1
            rm -rf "\(currentAppURL.path)"
            cp -R "\(newAppURL.path)" "\(parentDir.path)/"
            open "\(currentAppURL.path)"
            """
            
            try scriptContent.write(to: scriptPath, atomically: true, encoding: .utf8)
            
            // Даем скрипту права на исполнение
            let chmodProcess = Process()
            chmodProcess.executableURL = URL(fileURLWithPath: "/bin/chmod")
            chmodProcess.arguments = ["+x", scriptPath.path]
            try chmodProcess.run()
            chmodProcess.waitUntilExit()
            
            // 5. Запускаем скрипт в независимом процессе и гасим текущее приложение
            logger.log("🚀 UpdateInstaller: передача управления скрипту обновления и перезапуск...")
            let runScriptProcess = Process()
            runScriptProcess.executableURL = scriptPath
            try runScriptProcess.run()
            
            // Завершаем работу приложения
            NSApplication.shared.terminate(nil)
            
        } catch {
            logger.log("❌ UpdateInstaller ошибка установки: \(error.localizedDescription)")
        }
    }
}
