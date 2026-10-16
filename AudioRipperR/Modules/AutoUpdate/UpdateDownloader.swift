//
//  UpdateDownloader.swift
//  AudioRipperR
//
//  Created by Руслан on 10/17/26.
//

import Foundation

final class UpdateDownloader: NSObject, URLSessionDownloadDelegate {
    private static let logger = SessionLogger.shared
    
    var onProgressUpdate: ((Double) -> Void)?
    var onCompletion: ((Result<URL, Error>) -> Void)?
    
    private var continuation: CheckedContinuation<URL, Error>?

    func download(from urlString: String) async throws -> URL {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "UpdateDownloader", code: 400, userInfo: [NSLocalizedDescriptionKey: "Неверный URL для скачивания обновления"])
        }
        
        Self.logger.log("📥 UpdateDownloader: запуск загрузки файла...")
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let task = session.downloadTask(with: url)
            task.resume()
        }
    }

    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        Self.logger.log("✅ UpdateDownloader: файл успешно скачан в кэш")
        
        let destinationPath = FileManager.default.temporaryDirectory.appendingPathComponent("AudioRipperR_Update.zip")
        
        do {
            if FileManager.default.fileExists(atPath: destinationPath.path) {
                try FileManager.default.removeItem(at: destinationPath)
            }
            try FileManager.default.moveItem(at: location, to: destinationPath)
            
            Self.logger.log("📁 UpdateDownloader: архив перемещен во временную папку")
            
            Task { @MainActor in
                self.onCompletion?(.success(destinationPath))
                self.continuation?.resume(returning: destinationPath)
                self.continuation = nil
            }
        } catch {
            Self.logger.log("❌ UpdateDownloader ошибка перемещения файла: \(error.localizedDescription)")
            Task { @MainActor in
                self.onCompletion?(.failure(error))
                self.continuation?.resume(throwing: error)
                self.continuation = nil
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        Task { @MainActor in
            self.onProgressUpdate?(progress)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            Self.logger.log("❌ UpdateDownloader ошибка сессии: \(error.localizedDescription)")
            Task { @MainActor in
                self.onCompletion?(.failure(error))
                self.continuation?.resume(throwing: error)
                self.continuation = nil
            }
        }
    }
}
