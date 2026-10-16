import Foundation
import Observation

struct TrackItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let duration: String
    let url: String
    var isSelected: Bool = true
}

@Observable
final class PlaylistTableLogic {
    private let logger = SessionLogger.shared
    
    var tracks: [TrackItem] {
        get { GlobalState.shared.tracks }
        set {
            GlobalState.shared.tracks = newValue
            logger.log("📋 PlaylistTableLogic: список треков обновлен. Всего элементов: \(newValue.count)")
        }
    }
}

