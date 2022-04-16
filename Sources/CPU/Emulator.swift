public class Emulator {
    var cpu = CPU()

    var cpuBus: Bus
    var cpuTicker: Ticker

    init(bus: Bus, ticker: Ticker) {
        self.cpuBus = bus
        self.cpuTicker = ticker
    }

    public func step() {
        let opcode = fetch()
        let instruction = decode(opcode)
        execute(instruction)
    }

    public func powerOn() {
        cpu.A = 0
        cpu.X = 0
        cpu.Y = 0
        cpu.S = 0xFD
        cpu.P = Status(rawValue: 0x34)
    }
}

public protocol Bus {
    func read(_ addr: UInt16) -> UInt8
    func write(_ addr: UInt16, _ value: UInt8)
}

public protocol Ticker {
    func tick()
}

extension Emulator {
    func fetch() -> UInt8 {
        let opcode = read(cpu.PC)
        cpu.PC &+= 1
        return opcode
    }
}

extension Emulator {
    func read(_ addr: UInt16) -> UInt8 {
        let value = cpuBus.read(addr)
        tick()
        return value
    }

    func write(_ addr: UInt16, _ value: UInt8)  {
        //TODO OAMDMA
        cpuBus.write(addr, value)
        tick()
    }

    func readWord(_ addr: UInt16) -> UInt16 {
        return read(addr).u16 | (read(addr + 1).u16 << 8)
    }

    func readOnIndirect(_ addr: UInt16) -> UInt16 {
        return 0
    }
}

extension Emulator {
    @inline(__always)
    func tick() {
        cpuTicker.tick()
    }

    func tick(count: Int) {
        for _ in 0..<count {
            tick()
        }
    }
}

extension Emulator {
    @inline(__always)
    func pushStack(_ value: UInt8) {
        write(cpu.S.u16 &+ 0x100, value)
        cpu.S &-= 1
    }

    @inline(__always)
    func pushStack(word: UInt16) {
        pushStack(UInt8(word >> 8))
        pushStack(UInt8(word & 0xFF))
    }

    @inline(__always)
    func pullStack() -> UInt8 {
        cpu.S &+= 1
        return read(cpu.S.u16 &+ 0x100)
    }

    @inline(__always)
    func pullStack() -> UInt16 {
        let lo: UInt8 = pullStack()
        let ho: UInt8 = pullStack()
        return ho.u16 &<< 8 | lo.u16
    }
}
