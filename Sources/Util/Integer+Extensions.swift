extension UInt8 {
    @inline(__always)
    public var u16: UInt16 {
        return UInt16(self)
    }

    @inline(__always)
    public subscript(n: UInt8) -> UInt8 {
        return (self &>> n) & 1
    }
}

extension UInt16 {
    @inline(__always)
    public var i8: Int8 {
        return Int8(bitPattern: UInt8(self))
    }
}
