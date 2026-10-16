import Foundation
import Observation

@Observable
final class GlobalState {
    static let shared = GlobalState()
    
    var outputDirectory: URL = FileManager.default.urls(for: .musicDirectory, in: .userDomainMask).first!
    var selectedAudioFormat: String = "mp3"
    
    private init() {}
}
