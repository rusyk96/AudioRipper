import Foundation

final class YTProcessRunner {
    private static let logger = SessionLogger.shared
    
    static func run(executablePath: String, arguments: [String], onOutput: @escaping (String) -> Void) async throws {
        logger.log("🛠 YTProcessRunner: старт системного процесса. Исполняемый файл: (скрыт), аргументов: \(arguments.count)")
        
        // Гарантированно делаем бинарник исполняемым
        let chmodTask = Process()
        chmodTask.executableURL = URL(fileURLWithPath: "/bin/chmod")
        chmodTask.arguments = ["+x", executablePath]
        try? chmodTask.run()
        chmodTask.waitUntilExit()
        
        let task = Process()
        let pipe = Pipe()
        
        task.executableURL = URL(fileURLWithPath: executablePath)
        task.arguments = arguments
        task.standardOutput = pipe
        task.standardError = pipe
        
        var fullOutput = ""
        
        pipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                fullOutput += output
                onOutput(output)
            }
        }
        
        try task.run()
        task.waitUntilExit()
        
        logger.log("🏁 YTProcessRunner: процесс завершил работу с кодом возврата: \(task.terminationStatus)")
        if task.terminationStatus != 0 {
            logger.log("❌ YTProcessRunner: зафиксирована ошибка выполнения процесса (код не равен 0)")
        }
    }
}





