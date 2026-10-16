import SwiftUI

struct PlaylistTableBinding: View {
    private static let logger = SessionLogger.shared
    @State private var logic = PlaylistTableLogic()
    
    var body: some View {
        let _ = Self.logger.log("🧩 UI Binding: инициализация PlaylistTableBinding")
        return PlaylistTableView(logic: logic)
    }
}

