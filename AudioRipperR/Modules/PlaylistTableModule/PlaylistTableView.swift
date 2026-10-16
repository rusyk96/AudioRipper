import SwiftUI

struct PlaylistTableView: View {
    private static let logger = SessionLogger.shared
    @Bindable var logic: PlaylistTableLogic
    
    var body: some View {
        Group {
            if logic.tracks.isEmpty {
                let _ = Self.logger.log("📭 UI View: отображение пустого состояния плейлиста")
                ContentUnavailableView(
                    "Плейлист пуст",
                    systemImage: "music.note.list",
                    description: Text("Вставьте ссылку и нажмите «Загрузить список треков»")
                )
            } else {
                let _ = Self.logger.log("📜 UI View: рендеринг списка треков (элементов: \(logic.tracks.count))")
                List($logic.tracks) { $track in
                    HStack {
                        Toggle("", isOn: $track.isSelected)
                            .labelsHidden()
                        
                        Text(track.title)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(track.duration)
                            .foregroundColor(.secondary)
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
            }
        }
        .frame(minHeight: 200, maxHeight: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

