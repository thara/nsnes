import XCTest
@testable import CPU

final class AddressingModeTest: XCTestCase {
    var mem = [UInt8]()
    var cycle = Cycle()

    override func setUp() {
        mem = [UInt8](repeating: 0, count: 0x10000)
        cycle.value = 0
    }

    func test_getOperand_implicit() throws {
        // Arrange
        let emu = Emulator(bus: mem, ticker: cycle)
        // Act
        let result = emu.getOperand(.implicit)
        // Assert
        XCTAssertEqual(result, 0)
        XCTAssertEqual(cycle.value, 0)
    }

    func test_getOperand_accumulator() throws {
        // Arrange
        let emu = Emulator(bus: mem, ticker: cycle)
        emu.cpu.A = 0xFB
        // Act
        let result = emu.getOperand(.accumulator)
        // Assert
        XCTAssertEqual(result, 0xFB)
        XCTAssertEqual(cycle.value, 0)
    }

    func test_getOperand_immediate() throws {
        // Arrange
        let emu = Emulator(bus: mem, ticker: cycle)
        emu.cpu.PC = 0x8234
        // Act
        let result = emu.getOperand(.immediate)
        // Assert
        XCTAssertEqual(result, 0x8234)
        XCTAssertEqual(emu.cpu.PC, 0x8235)
        XCTAssertEqual(cycle.value, 0)
    }

    func test_getOperand_zeroPage() throws {
        // Arrange
        let emu = Emulator(bus: mem, ticker: cycle)
        emu.cpu.PC = 0x0414
        emu.cpuBus.write(0x0414, 0x91)
        // Act
        let result = emu.getOperand(.zeroPage)
        // Assert
        XCTAssertEqual(result, 0x91)
        XCTAssertEqual(emu.cpu.PC, 0x0415)
        XCTAssertEqual(cycle.value, 1)
    }

    func test_getOperand_zeroPageX() throws {
        // Arrange
        let emu = Emulator(bus: mem, ticker: cycle)
        emu.cpu.PC = 0x0100
        emu.cpu.X = 0x93
        emu.cpuBus.write(0x0100, 0x80)
        // Act
        let result = emu.getOperand(.zeroPageX)
        // Assert
        XCTAssertEqual(result, 0x13)
        XCTAssertEqual(emu.cpu.PC, 0x0101)
        XCTAssertEqual(cycle.value, 2)
    }

    func test_getOperand_zeroPageY() throws {
        // Arrange
        let emu = Emulator(bus: mem, ticker: cycle)
        emu.cpu.PC = 0x0423
        emu.cpu.Y = 0xF1
        emu.cpuBus.write(0x0423, 0x36)
        // Act
        let result = emu.getOperand(.zeroPageY)
        // Assert
        XCTAssertEqual(result, 0x27)
        XCTAssertEqual(emu.cpu.PC, 0x0424)
        XCTAssertEqual(cycle.value, 2)
    }

    func test_getOperand_absolute() throws {
        // Arrange
        let emu = Emulator(bus: mem, ticker: cycle)
        emu.cpu.PC = 0x0423
        emu.cpuBus.write(0x0423, 0x36)
        emu.cpuBus.write(0x0424, 0xF0)
        // Act
        let result = emu.getOperand(.absolute)
        // Assert
        XCTAssertEqual(result, 0xF036)
        XCTAssertEqual(emu.cpu.PC, 0x0425)
        XCTAssertEqual(cycle.value, 2)
    }

    func test_getOperand_absoluteX() throws {
        mem.write(0x0423, 0x36)
        mem.write(0x0424, 0xF0)

        let cases: [(mode: AddressingMode, x: UInt8, expectedOperand: UInt16, expectedCycle: Int)] = [
            (mode: .absoluteX(penalty: false), x: 0x31, expectedOperand: 0xF067, expectedCycle: 3),
            (mode: .absoluteX(penalty: true), x: 0x31, expectedOperand: 0xF067, expectedCycle: 2),
            (mode: .absoluteX(penalty: true), x: 0xF0, expectedOperand: 0xF126, expectedCycle: 3),
        ]

        for (i, testCase) in cases.enumerated() {
            // Arrange
            cycle.value = 0
            let emu = Emulator(bus: mem, ticker: cycle)
            emu.cpu.PC = 0x0423
            emu.cpu.X = testCase.x
            // Act
            let result = emu.getOperand(testCase.mode)
            // Assert
            XCTAssertEqual(result, testCase.expectedOperand, "\(i)")
            XCTAssertEqual(emu.cpu.PC, 0x0425, "\(i)")
            XCTAssertEqual(cycle.value, testCase.expectedCycle, "\(i)")
        }
    }

    func test_getOperand_absoluteY() throws {
        mem.write(0x0423, 0x36)
        mem.write(0x0424, 0xF0)

        let cases: [(mode: AddressingMode, y: UInt8, expectedOperand: UInt16, expectedCycle: Int)] = [
            (mode: .absoluteY(penalty: false), y: 0x31, expectedOperand: 0xF067, expectedCycle: 3),
            (mode: .absoluteY(penalty: true), y: 0x31, expectedOperand: 0xF067, expectedCycle: 2),
            (mode: .absoluteY(penalty: true), y: 0xF0, expectedOperand: 0xF126, expectedCycle: 3),
        ]
        for (i, testCase) in cases.enumerated() {
            // Arrange
            cycle.value = 0
            let emu = Emulator(bus: mem, ticker: cycle)
            emu.cpu.PC = 0x0423
            emu.cpu.Y = testCase.y
            // Act
            let result = emu.getOperand(testCase.mode)
            // Assert
            XCTAssertEqual(result, testCase.expectedOperand, "\(i)")
            XCTAssertEqual(emu.cpu.PC, 0x0425, "\(i)")
            XCTAssertEqual(cycle.value, testCase.expectedCycle, "\(i)")
        }
    }

    func test_getOperand_relative() throws {
        // Arrange
        let emu = Emulator(bus: mem, ticker: cycle)
        emu.cpu.PC = 0x0414
        emu.cpuBus.write(0x0414, 0x91)
        // Act
        let result = emu.getOperand(.relative)
        // Assert
        XCTAssertEqual(result, 0x91)
        XCTAssertEqual(cycle.value, 1)
    }

    func test_getOperand_indirect() throws {
        // Arrange
        let emu = Emulator(bus: mem, ticker: cycle)
        emu.cpu.PC = 0x020F
        emu.cpuBus.write(0x020F, 0x10)
        emu.cpuBus.write(0x0210, 0x03)
        emu.cpuBus.write(0x0310, 0x9F)
        // Act
        let result = emu.getOperand(.indirect)
        // Assert
        XCTAssertEqual(result, 0x9F)
        XCTAssertEqual(emu.cpu.PC, 0x0211)
        XCTAssertEqual(cycle.value, 4)
    }

    func test_getOperand_indexedIndirect() throws {
        // Arrange
        let emu = Emulator(bus: mem, ticker: cycle)
        emu.cpu.PC = 0x020F
        emu.cpu.X = 0x95
        emu.cpuBus.write(0x020F, 0xF0)
        emu.cpuBus.write(0x0085, 0x12)
        emu.cpuBus.write(0x0086, 0x90)
        // Act
        let result = emu.getOperand(.indexedIndirect)
        // Assert
        XCTAssertEqual(result, 0x9012)
        XCTAssertEqual(cycle.value, 4)
    }

    func test_getOperand_indirectIndexed() throws {

        let cases: [(mode: AddressingMode, Y: UInt8, expectedOperand: UInt16, expectedCycle: Int)] = [
            (mode: .indirectIndexed, Y: 0x83, expectedOperand: 0x9095, expectedCycle: 3),
            (mode: .indirectIndexed, Y: 0xF3, expectedOperand: 0x9105, expectedCycle: 4),
        ]
        for (i, testCase) in cases.enumerated() {
            // Arrange
            cycle.value = 0
            let emu = Emulator(bus: mem, ticker: cycle)
            emu.cpu.PC = 0x020F
            emu.cpu.Y = testCase.Y

            emu.cpuBus.write(0x020F, 0xF0)
            emu.cpuBus.write(0x00F0, 0x12)
            emu.cpuBus.write(0x00F1, 0x90)
            // Act
            let result = emu.getOperand(testCase.mode)
            // Assert
            XCTAssertEqual(result, testCase.expectedOperand, "\(i)")
            XCTAssertEqual(emu.cpu.PC, 0x210, "\(i)")
            XCTAssertEqual(cycle.value, testCase.expectedCycle, "\(i)")
        }
    }
}
