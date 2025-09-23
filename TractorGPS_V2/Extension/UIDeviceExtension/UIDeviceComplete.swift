//
// UIDeviceComplete.swift
//

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

public final class UIDeviceComplete<Base> {
    let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol UIDeviceCompleteCompatible {
    associatedtype CompatibleType

    var dc: CompatibleType { get }
}

public extension UIDeviceCompleteCompatible {
    var dc: UIDeviceComplete<Self> {
        return UIDeviceComplete(self)
    }
}

#if os(iOS)
extension UIDevice: UIDeviceCompleteCompatible { }
#elseif os(watchOS)
extension WKInterfaceDevice: UIDeviceCompleteCompatible { }
#endif
