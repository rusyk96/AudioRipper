//
//  SessionLogger.swift
//  AudioRipperR
//
//  Created by Руслан on 10/17/26.
//

import Foundation

final class SessionLogger {
    static let shared = SessionLogger()
    
    private let queue = DispatchQueue(label: "com.hiro.sessionlogger.queue", qos: .utility)
    private var logFileUrl: URL?
    
    private init() {
        setupLogFile()
    }
    
    private func setupLogFile() {
        let fileManager = FileManager.default
        guard let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let logsDir = docsDir.appendingPathComponent("AppLogs", isDirectory: true)
        try? fileManager.createDirectory(at: logsDir, withIntermediateDirectories: true)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        
        logFileUrl = logsDir.appendingPathComponent("session_\(timestamp).log")
        log("📁 Лог-сессия инициализирована в файле")
    }
    
    func startNewSession() {
        queue.async {
            self.setupLogFile()
        }
    }
    
    func log(_ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let formattedMessage = "[\(timestamp)] \(message)\n"
        
        // Дублируем в консоль для отладки
        print(formattedMessage.trimmingCharacters(in: .newlines))
        
        guard let fileUrl = logFileUrl else { return }
        queue.async {
            if let data = formattedMessage.data(using: .utf8) {
                if FileManager.default.fileExists(atPath: fileUrl.path) {
                    if let fileHandle = try? FileHandle(forWritingTo: fileUrl) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        try? fileHandle.close()
                    }
                } else {
                    try? data.write(to: fileUrl, options: .atomic)
                }
            }
        }
    }
}
