import SwiftUI

struct ParseButtonBinding: View {
    private static let logger = SessionLogger.shared
    @State private var logic = ParseButtonLogic()
    
    var body: some View {
        let _ = Self.logger.log("🧩 UI Binding: инициализация ParseButtonBinding")
        return ParseButtonView(logic: logic)
    }
}

