import SwiftUI

struct URLInputBinding: View {
    private static let logger = SessionLogger.shared
    @State private var logic = URLInputLogic()
    
    var body: some View {
        let _ = Self.logger.log("🧩 UI Binding: инициализация URLInputBinding")
        return URLInputView(logic: logic)
    }
}

