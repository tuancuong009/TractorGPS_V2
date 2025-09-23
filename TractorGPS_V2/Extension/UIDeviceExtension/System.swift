//
// System.swift
//

import Foundation

class System {
    static var name: String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let identifier = withUnsafePointer(to: &systemInfo.machine, {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(_SYS_NAMELEN)) {
                ptr in String(cString: ptr)
            }
        })
        // Simulator Check
        if identifier == "x86_64" || identifier == "i386" || identifier == "arm64" {
            return ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"]
        }
        return identifier
    }
}
