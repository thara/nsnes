func decode(_ opcode: UInt8) -> Instruction {
    return instructions[Int(opcode)]
}

fileprivate var instructions: [Instruction] = Array(unsafeUninitializedCapacity: 0xFF) { buffer, count in
    for i in 0x00..<0xFF {
        buffer[i] = buildInstruction(opcode: UInt8(i))
    }
    count = 0xFF
}

fileprivate func buildInstruction(opcode: UInt8) -> Instruction {
    switch opcode {
    case 0xA9:
        return (.LDA, addressingMode: .immediate)
    case 0xA5:
        return (.LDA, .zeroPage)
    case 0xB5:
        return (.LDA, .zeroPageX)
    case 0xAD:
        return (.LDA, .absolute)
    case 0xBD:
        return (.LDA, .absoluteX(penalty: true))
    case 0xB9:
        return (.LDA, .absoluteY(penalty: true))
    case 0xA1:
        return (.LDA, .indexedIndirect)
    case 0xB1:
        return (.LDA, .indirectIndexed)
    case 0xA2:
        return (.LDX, .immediate)
    case 0xA6:
        return (.LDX, .zeroPage)
    case 0xB6:
        return (.LDX, .zeroPageY)
    case 0xAE:
        return (.LDX, .absolute)
    case 0xBE:
        return (.LDX, .absoluteY(penalty: true))
    case 0xA0:
        return (.LDY, .immediate)
    case 0xA4:
        return (.LDY, .zeroPage)
    case 0xB4:
        return (.LDY, .zeroPageX)
    case 0xAC:
        return (.LDY, .absolute)
    case 0xBC:
        return (.LDY, .absoluteX(penalty: true))
    case 0x85:
        return (.STA, .zeroPage)
    case 0x95:
        return (.STA, .zeroPageX)
    case 0x8D:
        return (.STA, .absolute)
    case 0x9D:
        return (.STA, .absoluteX(penalty: false))
    case 0x99:
        return (.STA, .absoluteY(penalty: false))
    case 0x81:
        return (.STA, .indexedIndirect)
    case 0x91:
        return (.STA, .indirectIndexed)
    case 0x86:
        return (.STX, .zeroPage)
    case 0x96:
        return (.STX, .zeroPageY)
    case 0x8E:
        return (.STX, .absolute)
    case 0x84:
        return (.STY, .zeroPage)
    case 0x94:
        return (.STY, .zeroPageX)
    case 0x8C:
        return (.STY, .absolute)
    case 0xAA:
        return (.TAX, .implicit)
    case 0xBA:
        return (.TSX, .implicit)
    case 0xA8:
        return (.TAY, .implicit)
    case 0x8A:
        return (.TXA, .implicit)
    case 0x9A:
        return (.TXS, .implicit)
    case 0x98:
        return (.TYA, .implicit)

    case 0x48:
        return (.PHA, .implicit)
    case 0x08:
        return (.PHP, .implicit)
    case 0x68:
        return (.PLA, .implicit)
    case 0x28:
        return (.PLP, .implicit)

    case 0x29:
        return (.AND, .immediate)
    case 0x25:
        return (.AND, .zeroPage)
    case 0x35:
        return (.AND, .zeroPageX)
    case 0x2D:
        return (.AND, .absolute)
    case 0x3D:
        return (.AND, .absoluteX(penalty: true))
    case 0x39:
        return (.AND, .absoluteY(penalty: true))
    case 0x21:
        return (.AND, .indexedIndirect)
    case 0x31:
        return (.AND, .indirectIndexed)
    case 0x49:
        return (.EOR, .immediate)
    case 0x45:
        return (.EOR, .zeroPage)
    case 0x55:
        return (.EOR, .zeroPageX)
    case 0x4D:
        return (.EOR, .absolute)
    case 0x5D:
        return (.EOR, .absoluteX(penalty: true))
    case 0x59:
        return (.EOR, .absoluteY(penalty: true))
    case 0x41:
        return (.EOR, .indexedIndirect)
    case 0x51:
        return (.EOR, .indirectIndexed)
    case 0x09:
        return (.ORA, .immediate)
    case 0x05:
        return (.ORA, .zeroPage)
    case 0x15:
        return (.ORA, .zeroPageX)
    case 0x0D:
        return (.ORA, .absolute)
    case 0x1D:
        return (.ORA, .absoluteX(penalty: true))
    case 0x19:
        return (.ORA, .absoluteY(penalty: true))
    case 0x01:
        return (.ORA, .indexedIndirect)
    case 0x11:
        return (.ORA, .indirectIndexed)
    case 0x24:
        return (.BIT, .zeroPage)
    case 0x2C:
        return (.BIT, .absolute)

    case 0x69:
        return (.ADC, .immediate)
    case 0x65:
        return (.ADC, .zeroPage)
    case 0x75:
        return (.ADC, .zeroPageX)
    case 0x6D:
        return (.ADC, .absolute)
    case 0x7D:
        return (.ADC, .absoluteX(penalty: true))
    case 0x79:
        return (.ADC, .absoluteY(penalty: true))
    case 0x61:
        return (.ADC, .indexedIndirect)
    case 0x71:
        return (.ADC, .indirectIndexed)
    case 0xE9:
        return (.SBC, .immediate)
    case 0xE5:
        return (.SBC, .zeroPage)
    case 0xF5:
        return (.SBC, .zeroPageX)
    case 0xED:
        return (.SBC, .absolute)
    case 0xFD:
        return (.SBC, .absoluteX(penalty: true))
    case 0xF9:
        return (.SBC, .absoluteY(penalty: true))
    case 0xE1:
        return (.SBC, .indexedIndirect)
    case 0xF1:
        return (.SBC, .indirectIndexed)
    case 0xC9:
        return (.CMP, .immediate)
    case 0xC5:
        return (.CMP, .zeroPage)
    case 0xD5:
        return (.CMP, .zeroPageX)
    case 0xCD:
        return (.CMP, .absolute)
    case 0xDD:
        return (.CMP, .absoluteX(penalty: true))
    case 0xD9:
        return (.CMP, .absoluteY(penalty: true))
    case 0xC1:
        return (.CMP, .indexedIndirect)
    case 0xD1:
        return (.CMP, .indirectIndexed)
    case 0xE0:
        return (.CPX, .immediate)
    case 0xE4:
        return (.CPX, .zeroPage)
    case 0xEC:
        return (.CPX, .absolute)
    case 0xC0:
        return (.CPY, .immediate)
    case 0xC4:
        return (.CPY, .zeroPage)
    case 0xCC:
        return (.CPY, .absolute)

    case 0xE6:
        return (.INC, .zeroPage)
    case 0xF6:
        return (.INC, .zeroPageX)
    case 0xEE:
        return (.INC, .absolute)
    case 0xFE:
        return (.INC, .absoluteX(penalty: false))
    case 0xE8:
        return (.INX, .implicit)
    case 0xC8:
        return (.INY, .implicit)
    case 0xC6:
        return (.DEC, .zeroPage)
    case 0xD6:
        return (.DEC, .zeroPageX)
    case 0xCE:
        return (.DEC, .absolute)
    case 0xDE:
        return (.DEC, .absoluteX(penalty: false))
    case 0xCA:
        return (.DEX, .implicit)
    case 0x88:
        return (.DEY, .implicit)

    case 0x0A:
        return (.ASL, .accumulator)
    case 0x06:
        return (.ASL, .zeroPage)
    case 0x16:
        return (.ASL, .zeroPageX)
    case 0x0E:
        return (.ASL, .absolute)
    case 0x1E:
        return (.ASL, .absoluteX(penalty: false))
    case 0x4A:
        return (.LSR, .accumulator)
    case 0x46:
        return (.LSR, .zeroPage)
    case 0x56:
        return (.LSR, .zeroPageX)
    case 0x4E:
        return (.LSR, .absolute)
    case 0x5E:
        return (.LSR, .absoluteX(penalty: false))
    case 0x2A:
        return (.ROL, .accumulator)
    case 0x26:
        return (.ROL, .zeroPage)
    case 0x36:
        return (.ROL, .zeroPageX)
    case 0x2E:
        return (.ROL, .absolute)
    case 0x3E:
        return (.ROL, .absoluteX(penalty: false))
    case 0x6A:
        return (.ROR, .accumulator)
    case 0x66:
        return (.ROR, .zeroPage)
    case 0x76:
        return (.ROR, .zeroPageX)
    case 0x6E:
        return (.ROR, .absolute)
    case 0x7E:
        return (.ROR, .absoluteX(penalty: false))

    case 0x4C:
        return (.JMP, .absolute)
    case 0x6C:
        return (.JMP, .indirect)
    case 0x20:
        return (.JSR, .absolute)
    case 0x60:
        return (.RTS, .implicit)
    case 0x40:
        return (.RTI, .implicit)

    case 0x90:
        return (.BCC, .relative)
    case 0xB0:
        return (.BCS, .relative)
    case 0xF0:
        return (.BEQ, .relative)
    case 0x30:
        return (.BMI, .relative)
    case 0xD0:
        return (.BNE, .relative)
    case 0x10:
        return (.BPL, .relative)
    case 0x50:
        return (.BVC, .relative)
    case 0x70:
        return (.BVS, .relative)

    case 0x18:
        return (.CLC, .implicit)
    case 0xD8:
        return (.CLD, .implicit)
    case 0x58:
        return (.CLI, .implicit)
    case 0xB8:
        return (.CLV, .implicit)

    case 0x38:
        return (.SEC, .implicit)
    case 0xF8:
        return (.SED, .implicit)
    case 0x78:
        return (.SEI, .implicit)

    case 0x00:
        return (.BRK, .implicit)

    // Undocumented
    case 0xEB:
        return (.SBC, .immediate)

    case 0x04, 0x44, 0x64:
        return (.NOP, .zeroPage)
    case 0x0C:
        return (.NOP, .absolute)
    case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
        return (.NOP, .zeroPageX)
    case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
        return (.NOP, .implicit)
    case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
        return (.NOP, .absoluteX(penalty: true))
    case 0x80, 0x82, 0x89, 0xC2, 0xE2:
        return (.NOP, .immediate)

    case 0xA3:
        return (.LAX, .indexedIndirect)
    case 0xA7:
        return (.LAX, .zeroPage)
    case 0xAF:
        return (.LAX, .absolute)
    case 0xB3:
        return (.LAX, .indirectIndexed)
    case 0xB7:
        return (.LAX, .zeroPageY)
    case 0xBF:
        return (.LAX, .absoluteY(penalty: true))

    case 0x83:
        return (.SAX, .indexedIndirect)
    case 0x87:
        return (.SAX, .zeroPage)
    case 0x8F:
        return (.SAX, .absolute)
    case 0x97:
        return (.SAX, .zeroPageY)

    case 0xC3:
        return (.DCP, .indexedIndirect)
    case 0xC7:
        return (.DCP, .zeroPage)
    case 0xCF:
        return (.DCP, .absolute)
    case 0xD3:
        return (.DCP, .indirectIndexed)
    case 0xD7:
        return (.DCP, .zeroPageX)
    case 0xDB:
        return (.DCP, .absoluteY(penalty: false))
    case 0xDF:
        return (.DCP, .absoluteX(penalty: false))

    case 0xE3:
        return (.ISB, .indexedIndirect)
    case 0xE7:
        return (.ISB, .zeroPage)
    case 0xEF:
        return (.ISB, .absolute)
    case 0xF3:
        return (.ISB, .indirectIndexed)
    case 0xF7:
        return (.ISB, .zeroPageX)
    case 0xFB:
        return (.ISB, .absoluteY(penalty: false))
    case 0xFF:
        return (.ISB, .absoluteX(penalty: false))

    case 0x03:
        return (.SLO, .indexedIndirect)
    case 0x07:
        return (.SLO, .zeroPage)
    case 0x0F:
        return (.SLO, .absolute)
    case 0x13:
        return (.SLO, .indirectIndexed)
    case 0x17:
        return (.SLO, .zeroPageX)
    case 0x1B:
        return (.SLO, .absoluteY(penalty: false))
    case 0x1F:
        return (.SLO, .absoluteX(penalty: false))

    case 0x23:
        return (.RLA, .indexedIndirect)
    case 0x27:
        return (.RLA, .zeroPage)
    case 0x2F:
        return (.RLA, .absolute)
    case 0x33:
        return (.RLA, .indirectIndexed)
    case 0x37:
        return (.RLA, .zeroPageX)
    case 0x3B:
        return (.RLA, .absoluteY(penalty: false))
    case 0x3F:
        return (.RLA, .absoluteX(penalty: false))

    case 0x43:
        return (.SRE, .indexedIndirect)
    case 0x47:
        return (.SRE, .zeroPage)
    case 0x4F:
        return (.SRE, .absolute)
    case 0x53:
        return (.SRE, .indirectIndexed)
    case 0x57:
        return (.SRE, .zeroPageX)
    case 0x5B:
        return (.SRE, .absoluteY(penalty: false))
    case 0x5F:
        return (.SRE, .absoluteX(penalty: false))

    case 0x63:
        return (.RRA, .indexedIndirect)
    case 0x67:
        return (.RRA, .zeroPage)
    case 0x6F:
        return (.RRA, .absolute)
    case 0x73:
        return (.RRA, .indirectIndexed)
    case 0x77:
        return (.RRA, .zeroPageX)
    case 0x7B:
        return (.RRA, .absoluteY(penalty: false))
    case 0x7F:
        return (.RRA, .absoluteX(penalty: false))

    default:
        return (.NOP, .implicit)
    }
}
