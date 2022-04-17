extension Emulator {
    func handleInterrupt() -> Bool {
        guard let intr = interrupt else {
            return false
        }

        tick(count: 2)

        pushStack(word: cpu.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | Status.interruptedB.rawValue)
        cpu.P.formUnion(.I)
        cpu.PC = readWord(intr.vector)

        interrupt = nil
        return true
    }
}

extension Interrupt {
    var vector: UInt16 {
        switch self {
        case .NMI: return 0xFFFA
        case .IRQ: return 0xFFFE
        }
    }
}
