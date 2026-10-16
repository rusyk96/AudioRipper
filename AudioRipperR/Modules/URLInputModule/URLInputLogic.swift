import Foundation
import Observation

@Observable
final class URLInputLogic {
    private let logger = SessionLogger.shared
    
    var urlString: String {
        get { GlobalState.shared.urlString }
        set {
            GlobalState.shared.urlString = newValue
            logger.log("⌨️ URLInputLogic: изменение строки ввода URL (длина: \(newValue.count))")
        }
    }
    
    var isValid: Bool {
        let valid = GlobalState.shared.isValidUrl
        return valid
    }
    
    func validate() {
        // Реактивная валидация
    }
}


