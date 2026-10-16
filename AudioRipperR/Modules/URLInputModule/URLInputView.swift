import SwiftUI

struct URLInputView: View {
    private static let logger = SessionLogger.shared
    @Bindable var logic: URLInputLogic
    
    var body: some View {
        let _ = Self.logger.log("🎨 UI View: рендеринг URLInputView (валидность ссылки: \(logic.isValid))")
        
        return HStack(spacing: 12) {
            Image(systemName: "link")
                .foregroundColor(.secondary)
            
            TextField("Введите ссылку на плейлист или видео с YouTube...", text: $logic.urlString)
                .textFieldStyle(.plain)
                .onChange(of: logic.urlString) { _, _ in
                    logic.validate()
                }
            
            if logic.isValid {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.1)))
    }
}
