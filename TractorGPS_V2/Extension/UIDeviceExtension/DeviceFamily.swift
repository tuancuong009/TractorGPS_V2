//
// DeviceFamily.swift
//

public enum DeviceFamily: String {

    case iPhone
    case iPod
    case iPad
    case watch
    case unknown

    public init(rawValue: String) {
        switch rawValue {
        case "iPhone":
            self = .iPhone
        case "iPod":
            self = .iPod
        case "iPad":
            self = .iPad
        case "Watch":
            self = .watch
        default:
            self = .unknown
        }
    }
}

// MARK: Simulator Detection

extension DeviceFamily {
    public var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}
