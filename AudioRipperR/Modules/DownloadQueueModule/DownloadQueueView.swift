import SwiftUI

struct DownloadQueueView: View {
    private static let logger = SessionLogger.shared
    @Bindable var logic: DownloadQueueLogic
    
    var body: some View {
        HStack(spacing: 16) {
            if logic.isDownloading {
                let _ = Self.logger.log("📊 UI View: отображение прогресса загрузки (\(Int(logic.progress * 100))%)")
                ProgressView(value: logic.progress, total: 1.0)
                    .progressViewStyle(.linear)
            } else {
                let _ = Self.logger.log("💤 UI View: отображение состояния 'Готово к загрузке'")
                Text("Готово к загрузке")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Button(action: {
                logic.startDownload()
            }) {
                Text("Скачать выбранное")
            }
            .buttonStyle(.borderedProminent)
            .disabled(logic.isDownloading)
        }
    }
}
