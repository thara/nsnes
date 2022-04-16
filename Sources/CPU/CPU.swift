import Util

// CPU internal state
struct CPU {
    /// Accumulator
    var A: UInt8 = 0x00 { didSet { P.setZN(A) } }
    /// Index register
    var X: UInt8 = 0x00 { didSet { P.setZN(X) } }
    /// Index register
    var Y: UInt8 = 0x00 { didSet { P.setZN(Y) } }
    /// Stack pointer
    var S: UInt8 = 0xFF
    /// Status register
    var P: Status = []
    /// Program Counter
    var PC: UInt16 = 0x00
}

struct Status: OptionSet {
    let rawValue: UInt8
    /// Negative
    static let N = Status(rawValue: 1 << 7)
    /// Overflow
    static let V = Status(rawValue: 1 << 6)
    static let R = Status(rawValue: 1 << 5)
    static let B = Status(rawValue: 1 << 4)
    /// Decimal mode
    static let D = Status(rawValue: 1 << 3)
    /// IRQ prevention
    static let I = Status(rawValue: 1 << 2)
    /// Zero
    static let Z = Status(rawValue: 1 << 1)
    /// Carry
    static let C = Status(rawValue: 1 << 0)
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    static let operatedB = Status(rawValue: 0b110000)
    static let interruptedB = Status(rawValue: 0b100000)

    mutating func setZN(_ value: UInt8) {
        set(.Z, if: value == 0)
        set(.N, if: value[7] == 1)
    }

    mutating func set(_ flag: Status, if condition: Bool) {
        if condition {
            formUnion(flag)
        } else {
            remove(flag)
        }
    }
}

typealias Instruction = (Mnemonic, AddressingMode)

enum Mnemonic {
    // Load/Store Operations
    case LDA, LDX, LDY, STA, STX, STY
    // Register Operations
    case TAX, TSX, TAY, TXA, TXS, TYA
    // Stack instructions
    case PHA, PHP, PLA, PLP
    // Logical instructions
    case AND, EOR, ORA, BIT
    // Arithmetic instructions
    case ADC, SBC, CMP, CPX, CPY
    // Increment/Decrement instructions
    case INC, INX, INY, DEC, DEX, DEY
    // Shift instructions
    case ASL, LSR, ROL, ROR
    // Jump instructions
    case JMP, JSR, RTS, RTI
    // Branch instructions
    case BCC, BCS, BEQ, BMI, BNE, BPL, BVC, BVS
    // Flag control instructions
    case CLC, CLD, CLI, CLV, SEC, SED, SEI
    // Misc
    case BRK, NOP
    // Unofficial
    case LAX, SAX, DCP, ISB, SLO, RLA, SRE, RRA
}

// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
enum AddressingMode {
    case implicit
    case accumulator
    case immediate
    case zeroPage, zeroPageX, zeroPageY
    case absolute
    case absoluteX(penalty: Bool)
    case absoluteY(penalty: Bool)
    case relative
    case indirect, indexedIndirect, indirectIndexed
}
