import SwiftUI

struct MainView: View {
    @State private var updateManager = UpdateManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("AudioRipperR")
                .font(.largeTitle)
                .bold()
            
            Text("Текущий статус: \(updateManager.statusMessage)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button("Проверить обновления вручную") {
                Task {
                    await updateManager.checkForUpdates()
                }
            }
        }
        .padding()
        .task {
            // Автоматическая проверка при запуске приложения
            await updateManager.checkForUpdates()
        }
        .sheet(isPresented: $updateManager.showUpdateAlert) {
            VStack(spacing: 16) {
                Text("✨ Доступно обновление!")
                    .font(.headline)
                
                if let info = updateManager.updateInfo {
                    Text("Версия: \(info.latestVersion)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Что нового:\n\(info.changelog)")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                }
                
                if updateManager.isDownloading {
                    VStack(spacing: 8) {
                        ProgressView(value: updateManager.downloadProgress)
                        Text("\(Int(updateManager.downloadProgress * 100))%")
                            .font(.caption)
                    }
                    .padding(.horizontal)
                } else {
                    HStack(spacing: 12) {
                        Button("Позже") {
                            updateManager.showUpdateAlert = false
                        }
                        
                        Button("Обновить сейчас") {
                            Task {
                                await updateManager.startUpdate()
                            }
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                }
            }
            .padding(24)
            .frame(width: 320)
        }
    }
}
