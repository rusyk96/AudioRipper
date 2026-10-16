import SwiftUI

@main
struct AudioRipperApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 700, minHeight: 550)
        }
        .windowResizability(.contentSize)
    }
}
