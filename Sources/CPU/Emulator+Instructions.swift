extension Emulator {
    func getOperand(_ addressingMode: AddressingMode) -> UInt16 {
        switch addressingMode {
        case .implicit:
            return 0x00
        case .accumulator:
            return cpu.A.u16
        case .immediate:
            let operand = cpu.PC
            cpu.PC &+= 1
            return operand
        case .zeroPage:
            let operand = read(cpu.PC).u16 & 0xFF
            cpu.PC &+= 1
            return operand
        case .zeroPageX:
            tick()
            let operand = (read(cpu.PC).u16 &+ cpu.X.u16) & 0xFF
            cpu.PC &+= 1
            return operand
        case .zeroPageY:
            tick()
            let operand = (read(cpu.PC).u16 &+ cpu.Y.u16) & 0xFF
            cpu.PC &+= 1
            return operand
        case .absolute:
            let operand = readWord(cpu.PC)
            cpu.PC &+= 2
            return operand
        case .absoluteX(let penalty):
            let data = readWord(cpu.PC)
            let operand = data &+ cpu.X.u16 & 0xFFFF
            cpu.PC &+= 2
            if !penalty {
                tick()
            } else if pageCrossed(value: data, operand: cpu.X) {
                tick()
            }

            return operand
        case .absoluteY(let penalty):
            let data = readWord(cpu.PC)
            let operand = data &+ cpu.Y.u16 & 0xFFFF
            cpu.PC &+= 2

            if !penalty {
                tick()
            } else if pageCrossed(value: data, operand: cpu.Y) {
                tick()
            }
            return operand
        case .relative:
            let operand = read(cpu.PC).u16
            cpu.PC &+= 1
            return operand
        case .indirect:
            let data = readWord(cpu.PC)
            let operand = readOnIndirect(data)
            cpu.PC &+= 2
            return operand
        case .indexedIndirect:
            let data = read(cpu.PC)
            let operand = readOnIndirect((data &+ cpu.X).u16 & 0xFF)
            cpu.PC &+= 1

            tick()

            return operand
        case .indirectIndexed:
            let data = read(cpu.PC).u16
            let operand = readOnIndirect(data) &+ cpu.Y.u16
            cpu.PC &+= 1

            if pageCrossed(value: operand &- cpu.Y.u16, operand: cpu.Y) {
                tick()
            }
            return operand
        }
    }

    func execute(_ instruction: Instruction) {
        let (_, addressingMode) = instruction
        let operand = getOperand(addressingMode)

        switch instruction {
        case (.LDA, _): cpu.A = read(operand)
        case (.LDX, _): cpu.X = read(operand)
        case (.LDY, _): cpu.Y = read(operand)
        case (.STA, .indirectIndexed):
            write(operand, cpu.A)
            tick()
        case (.STA, _): write(operand, cpu.A)
        case (.STX, _): write(operand, cpu.X)
        case (.STY, _): write(operand, cpu.Y)
        case (.TAX, _):
            cpu.X = cpu.A
            tick()
        case (.TSX, _):
            cpu.X = cpu.S
            tick()
        case (.TAY, _):
            cpu.Y = cpu.A
            tick()
        case (.TXA, _):
            cpu.A = cpu.X
            tick()
        case (.TXS, _):
            cpu.S = cpu.X
            tick()
        case (.TYA, _):
            cpu.A = cpu.Y
            tick()
        case (.PHA, _):
            pushStack(cpu.A)
            tick()
        case (.PHP, _):
            // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
            // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
            pushStack(cpu.P.rawValue | Status.operatedB.rawValue)
            tick()
        case (.PLA, _):
            cpu.A = pullStack()
            tick(count: 2)
        case (.PLP, _):
            // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
            // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
            cpu.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
            tick(count: 2)
        case (.AND, _):
            cpu.A &= read(operand)
        case (.EOR, _): eor(operand)
        case (.ORA, _): ora(operand)
        case (.BIT, _):
            let value = read(operand)
            let data = cpu.A & value
            cpu.P.set(.Z, if: data == 0)
            cpu.P.set(.V, if: value[6] == 1)
            cpu.P.set(.N, if: value[7] == 1)
        case (.ADC, _): adc(operand)
        case (.SBC, _): sbc(operand)
        case (.CMP, _): cmp(operand)
        case (.CPX, _):
            let value = read(operand)
            let cmp = cpu.X &- value
            cpu.P.setZN(cmp)
            cpu.P.set(.C, if: value <= cpu.X)
        case (.CPY, _):
            let value = read(operand)
            let cmp = cpu.Y &- value
            cpu.P.setZN(cmp)
            cpu.P.set(.C, if: value <= cpu.Y)
        case (.INC, _):
            let result = read(operand) &+ 1
            cpu.P.setZN(result)
            write(operand, result)
            tick()
        case (.INX, _):
            cpu.X &+= 1
            tick()
        case (.INY, _):
            cpu.Y &+= 1
            tick()
        case (.DEC, _):
            let result = read(operand) &- 1
            cpu.P.setZN(result)
            write(operand, result)
            tick()
        case (.DEX, _):
            cpu.X &-= 1
            tick()
        case (.DEY, _):
            cpu.Y &-= 1
            tick()
        case (.ASL, .accumulator):
            cpu.P.set(.C, if: cpu.A[7] == 1)
            cpu.A <<= 1
            tick()
        case (.ASL, _):
            var data = read(operand)
            cpu.P.set(.C, if: data[7] == 1)
            data <<= 1
            write(operand, data)
            tick()
        case (.LSR, .accumulator):
            cpu.P.set(.C, if: cpu.A[0] == 1)
            cpu.A >>= 1
            tick()
        case (.LSR, _):
            let data = read(operand)
            cpu.P.set(.C, if: data[0] == 1)
            tick()
        case (.ROL, .accumulator):
            let c = cpu.A & 0x80
            var a = cpu.A << 1
            if cpu.P.contains(.C) {
                a |= 0x01
            }
            cpu.P.set(.C, if: c == 0x80)
            cpu.A = a
            tick()
        case (.ROL, _):
            var data = read(operand)
            let c = data & 0x80
            data <<= 1
            if cpu.P.contains(.C) {
                data |= 0x01
            }
            cpu.P.set(.C, if: c == 0x80)
            write(operand, data)
            tick()
        case (.ROR, .accumulator):
            let c = cpu.A & 0x01
            var a = cpu.A >> 1
            if cpu.P.contains(.C) {
                a |= 0x80
            }
            cpu.P.set(.C, if: c == 1)
            cpu.A = a
            tick()
        case (.ROR, _):
            var data = read(operand)
            let c = data & 0x01
            data >>= 1
            if cpu.P.contains(.C) {
                data |= 0x80
            }
            cpu.P.set(.C, if: c == 1)
            cpu.P.setZN(data)
            write(operand, data)
            tick()
        case (.JMP, _): cpu.PC = operand
        case (.JSR, _):
            pushStack(word: cpu.PC &- 1)
            tick()
            cpu.PC = operand
        case (.RTS, _):
            tick(count: 3)
            cpu.PC = pullStack() &+ 1
        case (.RTI, _):
            tick(count: 2)
            // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
            // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
            cpu.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
            cpu.PC = pullStack()
        case (.BCC, _): branch(operand, if: !cpu.P.contains(.C))
        case (.BCS, _): branch(operand, if: cpu.P.contains(.C))
        case (.BEQ, _): branch(operand, if: cpu.P.contains(.Z))
        case (.BMI, _): branch(operand, if: cpu.P.contains(.N))
        case (.BNE, _): branch(operand, if: !cpu.P.contains(.Z))
        case (.BPL, _): branch(operand, if: !cpu.P.contains(.N))
        case (.BVC, _): branch(operand, if: !cpu.P.contains(.V))
        case (.BVS, _): branch(operand, if: cpu.P.contains(.V))
        case (.CLC, _):
            cpu.P.remove(.C)
            tick()
        case (.CLD, _):
            cpu.P.remove(.D)
            tick()
        case (.CLI, _):
            cpu.P.remove(.I)
            tick()
        case (.CLV, _):
            cpu.P.remove(.V)
            tick()
        case (.SEC, _):
            cpu.P.formUnion(.C)
            tick()
        case (.SED, _):
            cpu.P.formUnion(.D)
            tick()
        case (.SEI, _):
            cpu.P.formUnion(.I)
            tick()
        case (.BRK, _):
            pushStack(word: cpu.PC)
            // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
            // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
            pushStack(cpu.P.rawValue | Status.interruptedB.rawValue)
            tick()
            cpu.PC = readWord(0xFFFE)
        case (.NOP, _): tick()
        case (.LAX, _):
            let data = read(operand)
            cpu.A = data
            cpu.X = data
        case (.SAX, _):
            write(operand, cpu.A & cpu.X)
        case (.DCP, _):
            // DEC excluding tick
            let result = read(operand)
            cpu.P.setZN(result)
            write(operand, result)
            cmp(operand)
        case (.ISB, _):
            let result = read(operand)
            cpu.P.setZN(result)
            write(operand, result)
            cmp(operand)
        case (.SLO, _): 
            // ASL excluding tick
            var data = read(operand)
            cpu.P.set(.C, if: data[7] == 1)
            data <<= 1
            cpu.P.setZN(data)
            write(operand, data)
            sbc(operand)
        case (.RLA, _):
            // ROL excluding tick
            var data = read(operand)
            let c = data & 0x80
            data <<= 1
            if cpu.P.contains(.C) {
                data |= 0x01
            }
            cpu.P.set(.C, if: c == 0x80)
            cpu.P.setZN(data)
            write(operand, data)
            cpu.A &= read(operand)
        case (.SRE, _):
            // LSR exluding tick
            var data = read(operand)
            cpu.P.set(.C, if: data[0] == 1)
            data >>= 1
            cpu.P.setZN(data)
            eor(operand)
        case (.RRA, _):
            // ROR excluding tick
            var data = read(operand)
            let c = data & 0x01
            data >>= 1
            if cpu.P.contains(.C) {
                data |= 0x80
            }
            cpu.P.set(.C, if: c == 1)
            cpu.P.setZN(data)
            write(operand, data)
            adc(operand)
        }
    }

    fileprivate func eor(_ operand: UInt16) {
        cpu.A ^= read(operand)
    }

    fileprivate func ora(_ operand: UInt16) {
        cpu.A |= read(operand)
    }

    fileprivate func adc(_ operand: UInt16) {
        let a = cpu.A
        let val = read(operand)
        var result = a &+ val
        if cpu.P.contains(.C) {
            result &+= 1
        }
        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        cpu.P.set(.C, if: c7 == 1)
        cpu.P.set(.V, if: c6 ^ c7 == 1)
        cpu.A = result
    }

    fileprivate func sbc(_ operand: UInt16) {
        let a = cpu.A
        let val = ~read(operand)
        var result = a &+ val
        if cpu.P.contains(.C) {
            result &+= 1
        }
        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        cpu.P.set(.C, if: c7 == 1)
        cpu.P.set(.V, if: c6 ^ c7 == 1)
        cpu.A = result
    }

    fileprivate func cmp(_ operand: UInt16) {
        let cmp = Int16(cpu.A) &- Int16(read(operand))
        cpu.P.setZN(UInt8(cmp))
        cpu.P.set(.C, if: 0 <= cmp)
    }

    fileprivate func branch(_ operand: UInt16, if condition: Bool) {
        if !condition {
            return
        }
        tick()
        let pc = Int(cpu.PC)
        let offset = Int(operand.i8)
        if pageCrossed(value: pc, operand: offset) {
            tick()
        }
        cpu.PC = UInt16(pc &+ offset)
    }
}

func pageCrossed(value: UInt16, operand: UInt8) -> Bool {
    return pageCrossed(value: value, operand: operand.u16)
}

func pageCrossed(value: UInt16, operand: UInt16) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}

func pageCrossed(value: Int, operand: Int) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}
