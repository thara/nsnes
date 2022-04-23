@testable import CPU

extension Array: Bus where Element == UInt8 {
    @inline(__always)
    public func read(_ addr: UInt16) -> UInt8 {
        return self[Int(addr)]
    }

    @inline(__always)
    public mutating func write(_ addr: UInt16, _ value: UInt8) {
        self[Int(addr)] = value
    }
}

class Cycle {
    var value = 0
    init() {}
}

extension Cycle: Ticker {
    public func tick() {
        value += 1
    }
}
