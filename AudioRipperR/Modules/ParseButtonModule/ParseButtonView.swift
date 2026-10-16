import SwiftUI

struct ParseButtonView: View {
    private static let logger = SessionLogger.shared
    @Bindable var logic: ParseButtonLogic
    
    var body: some View {
        Button(action: {
            Self.logger.log("🖱️ UI View: пользователь кликнул на кнопку 'Загрузить список треков'")
            GlobalState.shared.parsePlaylist()
        }) {
            HStack(spacing: 8) {
                if GlobalState.shared.isParsing {
                    let _ = Self.logger.log("🔄 UI View: отображение индикатора процесса сканирования")
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "list.bullet.rectangle.portrait")
                }
                Text(GlobalState.shared.isParsing ? "Сканирование плейлиста..." : "Загрузить список треков")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .disabled(GlobalState.shared.isParsing || !GlobalState.shared.isValidUrl)
    }
}



