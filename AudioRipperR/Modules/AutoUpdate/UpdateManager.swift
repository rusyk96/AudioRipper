//
//  UpdateManager.swift
//  AudioRipperR
//
//  Created by Руслан on 10/17/26.
//

import Foundation

@Observable
final class UpdateManager: NSObject, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        <#code#>
    }
    
    private static let logger = SessionLogger.shared
    
    var isDownloading = false
    var downloadProgress: Double = 0.0
    var downloadedFileLocalURL: URL?
    var errorMessage: String?
    
    private var continuation: CheckedContinuation<URL, Error>?
    
    func downloadUpdate(from urlString: String) async throws -> URL {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "UpdateManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Неверный URL для скачивания обновления"])
        }
        
        Self.logger.log("📥 UpdateManager: старт загрузки обновления...")
        
        await MainActor.run {
            self.isDownloading = true
            self.downloadProgress = 0.0
            self.errorMessage = nil
        }
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let task = session.downloadTask(with: url)
            task.resume()
        }
    }
}
    
