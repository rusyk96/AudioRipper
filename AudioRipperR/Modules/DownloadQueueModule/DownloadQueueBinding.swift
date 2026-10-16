import SwiftUI

struct DownloadQueueBinding: View {
    private static let logger = SessionLogger.shared
    @State private var logic = DownloadQueueLogic()
    
    var body: some View {
        let _ = Self.logger.log("🧩 UI Binding: инициализация DownloadQueueBinding")
        return DownloadQueueView(logic: logic)
    }
}

