// Reference: ARM DDI 0487 (version L.a, 30 November 2024)
// https://developer.arm.com/documentation/ddi0487/la/

// MARK: Instruction Set

/// The A64 instruction set.
public struct A64InstructionSet: InstructionSet {
    /// An instruction in the A64 instruction set.
    public struct Instruction: Shellcode.Instruction {
        // "[A64] is a fixed-length instruction set that uses 32-bit instruction encodings." - A1.3.2
        public typealias EncodedForm = UInt32

        /// The raw bytes of the instruction.
        public var rawValue: [UInt8]
        /// Initializes the instruction with the given raw bytes.
        public init(rawValue: [UInt8]) {
            self.rawValue = rawValue
        }

        /// Initializes the instruction with the given raw instruction value.
        public init(encoded: UInt32) {
            self.rawValue = [
                UInt8(encoded & 0xFF),
                UInt8((encoded >> 8) & 0xFF),
                UInt8((encoded >> 16) & 0xFF),
                UInt8((encoded >> 24) & 0xFF),
            ]
        }
    }
}

extension A64InstructionSet.Instruction {
    // C4.1
    private static func encodedInstruction(op0: UInt8, op1: UInt8, additional: [Segment])
        -> UInt32
    {
        return encode(
            segments: [
                (op0, length: 1, shift: 31),
                (op1, length: 4, shift: 25),
            ] + additional
        )

    }
}

// MARK: IS | Reserved

extension A64InstructionSet.Instruction {
    // C4.1.1
    private static func encodeReservedInstruction(
        op0: UInt8, op1: UInt16, additional: [Segment]
    ) -> UInt32 {
        return encodedInstruction(
            op0: 0b0,
            op1: 0x000,
            additional: [
                (op0, length: 2, shift: 29),
                (op1, length: 9, shift: 16),
            ] + additional
        )
    }

    // C6.2.453
    public static func UDF(imm: UInt16) -> Self {
        return Self(
            encoded:
                encodeReservedInstruction(
                    op0: 0,
                    op1: 0,
                    additional: [
                        (imm, length: 16, shift: 0)
                    ]
                )
        )
    }
}

// TODO: Implement encoding of SME (C4.1.2) and SVE instructions (C4.1.35).

// MARK: Data Processing (Imm)

extension A64InstructionSet.Instruction {
    // C4.1.93
    private static func encodeDataProcessingImmediateInstruction(
        op0: UInt8,
        op1: UInt8,
        additional: [Segment] = []
    ) -> UInt32 {
        return encodedInstruction(
            op0: 0b0,  // Technically 0bx as the bit depends on the additional segments.
            op1: 0b1000,  // Technically 0b100x as the last bit depends on the additional segments.
            additional: [
                (op0, length: 2, shift: 29),
                (op1, length: 4, shift: 22),
            ] + additional
        )
    }
}

// MARK: DPI | 1 Source Immediate

extension A64InstructionSet.Instruction {
    // C4.1.93.1
    private static func encodeDataProcessing1SourceImmediateInstruction(
        sf: UInt8,
        opc: UInt8,
        imm16: UInt16,
        Rd: UInt8
    ) -> UInt32 {
        return encodeDataProcessingImmediateInstruction(
            op0: 0b11,
            op1: 0b1110,  // Technically 0b111x as the last bit depends on the additional segments.
            additional: [
                (sf, length: 1, shift: 31),
                (opc, length: 2, shift: 21),
                (imm16, length: 16, shift: 5),
                (Rd, length: 5, shift: 0),
            ]
        )
    }

    // C6.2.26
    public static func AUTIASPPC(imm: UInt16) -> Self {
        return Self(
            encoded: encodeDataProcessing1SourceImmediateInstruction(
                sf: 0b1,
                opc: 0b00,
                imm16: imm,
                Rd: 0b11111
            )
        )
    }

    // C6.2.30
    public static func AUTIBSPPC(imm: UInt16) -> Self {
        return Self(
            encoded: encodeDataProcessing1SourceImmediateInstruction(
                sf: 0b1,
                opc: 0b01,
                imm16: imm,
                Rd: 0b11111
            )
        )
    }
}

// MARK: DPI | PC-Rel. Addressing

extension A64InstructionSet.Instruction {
    // C4.1.93.2
    private static func encodePCRelativeAddressingInstruction(
        op: UInt8,
        immlo: UInt32,
        immhi: UInt32,
        Rd: UInt8
    ) -> UInt32 {
        return encodeDataProcessingImmediateInstruction(
            op0: 0b11,
            op1: 0b0000,  // Technically 0b00xx as the last two bits depends on the additional segments.
            additional: [
                (op, length: 1, shift: 31),
                (immlo, length: 2, shift: 29),
                (immhi, length: 19, shift: 5),
                (Rd, length: 5, shift: 0),
            ]
        )
    }

    // C6.2.12
    public static func ADR(Xd: UInt8, label: Int32) -> Self {
        return Self(
            encoded: encodePCRelativeAddressingInstruction(
                op: 0b0,
                immlo: UInt32(label & 0b11),
                immhi: UInt32((label >> 2) & 0b111_11111111_11111111),
                Rd: Xd
            )
        )
    }

    // C6.2.13
    public static func ADRP(Xd: UInt8, label: Int32) -> Self {
        return Self(
            encoded: encodePCRelativeAddressingInstruction(
                op: 0b0,
                immlo: UInt32(label & 0b11),
                immhi: UInt32((label >> 2) & 0b111_11111111_11111111),
                Rd: Xd
            )
        )
    }
}

// MARK: DPI | Add/Sub (Imm)

extension A64InstructionSet.Instruction {

    // C4.1.93.3
    private static func encodeAddSubtractImmediateInstruction(
        sf: UInt8,
        op: UInt8,
        S: UInt8,
        sh: UInt8,
        imm12: UInt16,
        Rn: UInt8,
        Rd: UInt8
    ) -> UInt32 {
        return encodeDataProcessingImmediateInstruction(
            op0: 0b11,
            op1: 0b0000,  // Technically 0b010x as the last bit depends on the additional segments.
            additional: [
                (sf, length: 1, shift: 31),
                (op, length: 1, shift: 30),
                (S, length: 1, shift: 29),
                (sh, length: 1, shift: 22),
                (imm12, length: 12, shift: 10),
                (Rn, length: 5, shift: 5),
                (Rd, length: 5, shift: 0),
            ]
        )
    }

    // C6.2.5
    public static func ADD(Wd: UInt8, Wn: UInt8, imm: UInt16, shift: Bool) -> Self {
        return Self(
            encoded: encodeAddSubtractImmediateInstruction(
                sf: 0b0,
                op: 0b0,
                S: 0b0,
                sh: shift ? 0b1 : 0b0,
                imm12: imm,
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.5
    public static func ADD(Xd: UInt8, Xn: UInt8, imm: UInt16, shift: Bool) -> Self {
        return Self(
            encoded: encodeAddSubtractImmediateInstruction(
                sf: 0b1,
                op: 0b0,
                S: 0b0,
                sh: shift ? 0b1 : 0b0,
                imm12: imm,
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.250
    public static func MOV(Wd: UInt8, Wn: UInt8) -> Self {
        return ADD(Wd: Wd, Wn: Wn, imm: 0, shift: false)
    }

    // C6.2.250
    public static func MOV(Xd: UInt8, Xn: UInt8) -> Self {
        return ADD(Xd: Xd, Xn: Xn, imm: 0, shift: false)
    }

    // C6.2.10
    public static func ADDS(Wd: UInt8, Wn: UInt8, imm: UInt16, shift: Bool) -> Self {
        return Self(
            encoded: encodeAddSubtractImmediateInstruction(
                sf: 0b0,
                op: 0b0,
                S: 0b1,
                sh: shift ? 0b1 : 0b0,
                imm12: imm,
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.10
    public static func ADDS(Xd: UInt8, Xn: UInt8, imm: UInt16, shift: Bool) -> Self {
        return Self(
            encoded: encodeAddSubtractImmediateInstruction(
                sf: 0b1,
                op: 0b0,
                S: 0b1,
                sh: shift ? 0b1 : 0b0,
                imm12: imm,
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.70
    public static func CMN(Wn: UInt8, imm: UInt16, shift: Bool) -> Self {
        return ADDS(Wd: 0b11111, Wn: Wn, imm: imm, shift: shift)
    }

    // C6.2.70
    public static func CMN(Xn: UInt8, imm: UInt16, shift: Bool) -> Self {
        return ADDS(Xd: 0b11111, Xn: Xn, imm: imm, shift: shift)
    }

    // C6.2.418
    public static func SUB(Wd: UInt8, Wn: UInt8, imm: UInt16, shift: Bool) -> Self {
        return Self(
            encoded: encodeAddSubtractImmediateInstruction(
                sf: 0b0,
                op: 0b1,
                S: 0b0,
                sh: shift ? 0b1 : 0b0,
                imm12: imm,
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.418
    public static func SUB(Xd: UInt8, Xn: UInt8, imm: UInt16, shift: Bool) -> Self {
        return Self(
            encoded: encodeAddSubtractImmediateInstruction(
                sf: 0b1,
                op: 0b1,
                S: 0b0,
                sh: shift ? 0b1 : 0b0,
                imm12: imm,
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.425
    public static func SUBS(Wd: UInt8, Wn: UInt8, imm: UInt16, shift: Bool) -> Self {
        return Self(
            encoded: encodeAddSubtractImmediateInstruction(
                sf: 0b0,
                op: 0b1,
                S: 0b1,
                sh: shift ? 0b1 : 0b0,
                imm12: imm,
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.425
    public static func SUBS(Xd: UInt8, Xn: UInt8, imm: UInt16, shift: Bool) -> Self {
        return Self(
            encoded: encodeAddSubtractImmediateInstruction(
                sf: 0b1,
                op: 0b1,
                S: 0b1,
                sh: shift ? 0b1 : 0b0,
                imm12: imm,
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.73
    public static func CMP(Wn: UInt8, imm: UInt16, shift: Bool) -> Self {
        return SUBS(Wd: 0b11111, Wn: Wn, imm: imm, shift: shift)
    }

    // C6.2.73
    public static func CMP(Xn: UInt8, imm: UInt16, shift: Bool) -> Self {
        return SUBS(Xd: 0b11111, Xn: Xn, imm: imm, shift: shift)
    }
}

// MARK: DPI | A/S (Imm w/ Tags)

extension A64InstructionSet.Instruction {
    // C4.1.93.3
    private static func encodeAddSubtractImmediateWithTagsInstruction(
        sf: UInt8,
        op: UInt8,
        S: UInt8,
        imm6: UInt8,
        op3: UInt8,
        imm4: UInt8,
        Rn: UInt8,
        Rd: UInt8
    ) -> UInt32 {
        return encodeDataProcessingImmediateInstruction(
            op0: 0b11,
            op1: 0b0110,
            additional: [
                (sf, length: 1, shift: 31),
                (op, length: 1, shift: 30),
                (S, length: 1, shift: 29),
                (imm6, length: 6, shift: 16),
                (op3, length: 2, shift: 14),
                (imm4, length: 4, shift: 10),
                (Rn, length: 5, shift: 5),
                (Rd, length: 5, shift: 0),
            ]
        )
    }

    // C6.2.7
    /// Warning: This requires the Memory Tagging Extension (MTE) feature.
    public static func ADDG(Xd: UInt8, Xn: UInt8, uimm6: UInt8, uimm4: UInt8) -> Self {
        return Self(
            encoded: encodeAddSubtractImmediateWithTagsInstruction(
                sf: 0b1,
                op: 0b0,
                S: 0b0,
                imm6: uimm6 & 0b111111,
                op3: 0b00,
                imm4: uimm4 & 0b1111,
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.420
    /// Warning: This requires the Memory Tagging Extension (MTE) feature.
    public static func SUBG(Xd: UInt8, Xn: UInt8, uimm6: UInt8, uimm4: UInt8) -> Self {
        return Self(
            encoded: encodeAddSubtractImmediateWithTagsInstruction(
                sf: 0b1,
                op: 0b1,
                S: 0b0,
                imm6: uimm6 & 0b111111,
                op3: 0b00,
                imm4: uimm4 & 0b1111,
                Rn: Xn,
                Rd: Xd
            )
        )
    }
}

// // MARK: DPI | Min/Max (Imm)

extension A64InstructionSet.Instruction {
    private static func encodeMinMaxImmediateInstruction(
        sf: UInt8,
        op: UInt8,
        S: UInt8,
        opc: UInt8,
        imm8: Int8,
        Rn: UInt8,
        Rd: UInt8
    ) -> UInt32 {
        return encodeDataProcessingImmediateInstruction(
            op0: 0b11,
            op1: 0b0111,
            additional: [
                (sf, length: 1, shift: 31),
                (op, length: 1, shift: 30),
                (S, length: 1, shift: 29),
                (opc, length: 4, shift: 18),
                (imm8, length: 8, shift: 10),
                (Rn, length: 5, shift: 5),
                (Rd, length: 5, shift: 0),
            ]
        )
    }

    // C6.2.339
    /// Warning: This requires the Common Short Sequence Compression (CSSC) feature.
    public static func SMAX(Wd: UInt8, Wn: UInt8, simm: Int8) -> Self {
        return Self(
            encoded: encodeMinMaxImmediateInstruction(
                sf: 0b0,
                op: 0b0,
                S: 0b0,
                opc: 0b0000,
                imm8: simm,
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.339
    /// Warning: This requires the Common Short Sequence Compression (CSSC) feature.
    public static func SMAX(Xd: UInt8, Xn: UInt8, simm: Int8) -> Self {
        return Self(
            encoded: encodeMinMaxImmediateInstruction(
                sf: 0b1,
                op: 0b0,
                S: 0b0,
                opc: 0b0000,
                imm8: simm,
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.456
    /// Warning: This requires the Common Short Sequence Compression (CSSC) feature.
    public static func UMAX(Wd: UInt8, Wn: UInt8, uimm: UInt8) -> Self {
        return Self(
            encoded: encodeMinMaxImmediateInstruction(
                sf: 0b0,
                op: 0b0,
                S: 0b0,
                opc: 0b0001,
                imm8: Int8(uimm),
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.456
    /// Warning: This requires the Common Short Sequence Compression (CSSC) feature.
    public static func UMAX(Xd: UInt8, Xn: UInt8, uimm: UInt8) -> Self {
        return Self(
            encoded: encodeMinMaxImmediateInstruction(
                sf: 0b1,
                op: 0b0,
                S: 0b0,
                opc: 0b0001,
                imm8: Int8(uimm),
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.342
    /// Warning: This requires the Common Short Sequence Compression (CSSC) feature.
    public static func SMIN(Wd: UInt8, Wn: UInt8, simm: Int8) -> Self {
        return Self(
            encoded: encodeMinMaxImmediateInstruction(
                sf: 0b0,
                op: 0b0,
                S: 0b0,
                opc: 0b0010,
                imm8: simm,
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.342
    /// Warning: This requires the Common Short Sequence Compression (CSSC) feature.
    public static func SMIN(Xd: UInt8, Xn: UInt8, simm: Int8) -> Self {
        return Self(
            encoded: encodeMinMaxImmediateInstruction(
                sf: 0b1,
                op: 0b0,
                S: 0b0,
                opc: 0b0010,
                imm8: simm,
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.458
    /// Warning: This requires the Common Short Sequence Compression (CSSC) feature.
    public static func UMIN(Wd: UInt8, Wn: UInt8, uimm: UInt8) -> Self {
        return Self(
            encoded: encodeMinMaxImmediateInstruction(
                sf: 0b0,
                op: 0b0,
                S: 0b0,
                opc: 0b0011,
                imm8: Int8(uimm),
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.458
    /// Warning: This requires the Common Short Sequence Compression (CSSC) feature.
    public static func UMIN(Xd: UInt8, Xn: UInt8, uimm: UInt8) -> Self {
        return Self(
            encoded: encodeMinMaxImmediateInstruction(
                sf: 0b1,
                op: 0b0,
                S: 0b0,
                opc: 0b0011,
                imm8: Int8(uimm),
                Rn: Xn,
                Rd: Xd
            )
        )
    }
}

// MARK: DPI | Logical (Immediate)

extension A64InstructionSet.Instruction {
    // C4.1.93.6
    private static func encodeLogicalImmediateInstruction(
        sf: UInt8,
        opc: UInt8,
        N: UInt8,
        immr: UInt8,
        imms: UInt8,
        Rn: UInt8,
        Rd: UInt8
    ) -> UInt32 {
        return encodeDataProcessingImmediateInstruction(
            op0: 0b11,
            op1: 0b1000,  // Technically 0b100x as the last bit depends on the additional segments.
            additional: [
                (sf, length: 1, shift: 31),
                (opc, length: 2, shift: 29),
                (N, length: 1, shift: 22),
                (immr, length: 6, shift: 16),
                (imms, length: 6, shift: 10),
                (Rn, length: 5, shift: 5),
                (Rd, length: 5, shift: 0),
            ]
        )
    }

    // C6.2.14
    public static func AND(Wd: UInt8, Wn: UInt8, imm: UInt16) -> Self {
        return Self(
            encoded: encodeLogicalImmediateInstruction(
                sf: 0b0,
                opc: 0b00,
                N: 0b0,
                immr: UInt8(imm & 0b111111),
                imms: UInt8((imm >> 5) & 0b111111),
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.14
    public static func AND(Xd: UInt8, Xn: UInt8, imm: UInt16) -> Self {
        return Self(
            encoded: encodeLogicalImmediateInstruction(
                sf: 0b1,
                opc: 0b00,
                N: UInt8(imm >> 10) & 0b1,
                immr: UInt8(imm & 0b111111),
                imms: UInt8((imm >> 5) & 0b111111),
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C4.1.93.6
    public static func ORR(Wd: UInt8, Wn: UInt8, imm: UInt16) -> Self {
        return Self(
            encoded: encodeLogicalImmediateInstruction(
                sf: 0b0,
                opc: 0b01,
                N: 0b0,
                immr: UInt8(imm & 0b111111),
                imms: UInt8((imm >> 5) & 0b111111),
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C4.1.93.6
    public static func ORR(Xd: UInt8, Xn: UInt8, imm: UInt16) -> Self {
        return Self(
            encoded: encodeLogicalImmediateInstruction(
                sf: 0b1,
                opc: 0b01,
                N: UInt8(imm >> 10) & 0b1,
                immr: UInt8(imm & 0b111111),
                imms: UInt8((imm >> 5) & 0b111111),
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.132
    public static func EOR(Wd: UInt8, Wn: UInt8, imm: UInt16) -> Self {
        return Self(
            encoded: encodeLogicalImmediateInstruction(
                sf: 0b0,
                opc: 0b10,
                N: 0b0,
                immr: UInt8(imm & 0b111111),
                imms: UInt8((imm >> 5) & 0b111111),
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.132
    public static func EOR(Xd: UInt8, Xn: UInt8, imm: UInt16) -> Self {
        return Self(
            encoded: encodeLogicalImmediateInstruction(
                sf: 0b1,
                opc: 0b10,
                N: UInt8(imm >> 10) & 0b1,
                immr: UInt8(imm & 0b111111),
                imms: UInt8((imm >> 5) & 0b111111),
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.16
    public static func ANDS(Wd: UInt8, Wn: UInt8, imm: UInt16) -> Self {
        return Self(
            encoded: encodeLogicalImmediateInstruction(
                sf: 0b0,
                opc: 0b11,
                N: 0b0,
                immr: UInt8(imm & 0b111111),
                imms: UInt8((imm >> 5) & 0b111111),
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.16
    public static func ANDS(Xd: UInt8, Xn: UInt8, imm: UInt16) -> Self {
        return Self(
            encoded: encodeLogicalImmediateInstruction(
                sf: 0b1,
                opc: 0b11,
                N: UInt8(imm >> 10) & 0b1,
                immr: UInt8(imm & 0b111111),
                imms: UInt8((imm >> 5) & 0b111111),
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.446
    public static func TST(Wn: UInt8, imm: UInt16) -> Self {
        return ANDS(Wd: 0b11111, Wn: Wn, imm: imm)
    }

    // C6.2.446
    public static func TST(Xn: UInt8, imm: UInt16) -> Self {
        return ANDS(Wd: 0b11111, Wn: Xn, imm: imm)
    }
}

// MARK: DPI | Move Wide (Imm)

extension A64InstructionSet.Instruction {
    // C4.1.93.7
    private static func encodeMoveWideImmediateInstruction(
        sf: UInt8,
        opc: UInt8,
        hw: UInt8,
        imm16: UInt16,
        Rd: UInt8
    ) -> UInt32 {
        return encodeDataProcessingImmediateInstruction(
            op0: 0b11,
            op1: 0b1010,  // Technically 0b101x as the last bit depends on the additional segments.
            additional: [
                (sf, length: 1, shift: 31),
                (opc, length: 2, shift: 29),
                (hw, length: 2, shift: 21),
                (imm16, length: 16, shift: 5),
                (Rd, length: 5, shift: 0),
            ]
        )
    }

    // C6.2.253
    public static func MOVN(Wd: UInt8, imm: UInt16, shift: UInt8) -> Self {
        return Self(
            encoded: encodeMoveWideImmediateInstruction(
                sf: 0b0,
                opc: 0b00,
                hw: (shift / 16) & 0b11,
                imm16: imm,
                Rd: Wd
            )
        )
    }

    // C6.2.253
    public static func MOVN(Xd: UInt8, imm: UInt16, shift: UInt8) -> Self {
        return Self(
            encoded: encodeMoveWideImmediateInstruction(
                sf: 0b1,
                opc: 0b00,
                hw: (shift / 16) & 0b11,
                imm16: imm,
                Rd: Xd
            )
        )
    }

    // C6.2.254
    public static func MOVZ(Wd: UInt8, imm: UInt16, shift: UInt8) -> Self {
        return Self(
            encoded: encodeMoveWideImmediateInstruction(
                sf: 0b0,
                opc: 0b10,
                hw: (shift / 16) & 0b11,
                imm16: imm,
                Rd: Wd
            )
        )
    }

    // C6.2.254
    public static func MOVZ(Xd: UInt8, imm: UInt16, shift: UInt8) -> Self {
        return Self(
            encoded: encodeMoveWideImmediateInstruction(
                sf: 0b1,
                opc: 0b10,
                hw: (shift / 16) & 0b11,
                imm16: imm,
                Rd: Xd
            )
        )
    }

    // C6.2.252
    public static func MOVK(Wd: UInt8, imm: UInt16, shift: UInt8) -> Self {
        return Self(
            encoded: encodeMoveWideImmediateInstruction(
                sf: 0b0,
                opc: 0b11,
                hw: (shift / 16) & 0b11,
                imm16: imm,
                Rd: Wd
            )
        )
    }

    // C6.2.252
    public static func MOVK(Xd: UInt8, imm: UInt16, shift: UInt8) -> Self {
        return Self(
            encoded: encodeMoveWideImmediateInstruction(
                sf: 0b1,
                opc: 0b11,
                hw: (shift / 16) & 0b11,
                imm16: imm,
                Rd: Xd
            )
        )
    }
}

// MARK: DPI | Bitfield

extension A64InstructionSet.Instruction {
    // C4.1.93.8
    private static func encodeBitfieldImmediateInstruction(
        sf: Bool,
        opc: UInt8,
        N: Bool,
        immr: UInt8,
        imms: UInt8,
        Rn: UInt8,
        Rd: UInt8
    ) -> UInt32 {
        return encodeDataProcessingImmediateInstruction(
            op0: 0b11,
            op1: 0b1100,  // Technically 0b110x as the last bit depends on the additional segments.
            additional: [
                (sf ? 1 : 0, length: 1, shift: 31),
                (opc, length: 2, shift: 29),
                (N ? 1 : 0, length: 1, shift: 22),
                (immr, length: 6, shift: 16),
                (imms, length: 6, shift: 10),
                (Rn, length: 5, shift: 5),
                (Rd, length: 5, shift: 0),
            ]
        )
    }

    // C6.2.324
    public static func SBFM(
        Wd: UInt8, Wn: UInt8, immr: UInt8, imms: UInt8
    ) -> Self {
        return Self(
            encoded: encodeBitfieldImmediateInstruction(
                sf: false,
                opc: 0b00,
                N: false,
                immr: immr & 0b111111,
                imms: imms & 0b111111,
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.324
    public static func SBFM(
        Xd: UInt8, Xn: UInt8, immr: UInt8, imms: UInt8
    ) -> Self {
        return Self(
            encoded: encodeBitfieldImmediateInstruction(
                sf: true,
                opc: 0b00,
                N: true,
                immr: immr & 0b111111,
                imms: imms & 0b111111,
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.19
    public static func ASR(
        Wd: UInt8, Wn: UInt8, shift: UInt8
    ) -> Self {
        return SBFM(Wd: Wd, Wn: Wn, immr: shift, imms: 31)
    }

    // C6.2.19
    public static func ASR(
        Xd: UInt8, Xn: UInt8, shift: UInt8
    ) -> Self {
        return SBFM(Xd: Xd, Xn: Xn, immr: shift, imms: 63)
    }

    // C6.2.323
    public static func SBFIZ(
        Wd: UInt8, Wn: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return SBFM(Wd: Wd, Wn: Wn, immr: UInt8(-Int8(lsb) % 32), imms: width - 1)
    }

    // C6.2.323
    public static func SBFIZ(
        Xd: UInt8, Xn: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return SBFM(Xd: Xd, Xn: Xn, immr: UInt8(-Int8(lsb) % 64), imms: width - 1)
    }

    // C6.2.325
    public static func SBFX(
        Wd: UInt8, Wn: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return SBFM(Wd: Wd, Wn: Wn, immr: lsb, imms: lsb + width - 1)
    }

    // C6.2.325
    public static func SBFX(
        Xd: UInt8, Xn: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return SBFM(Xd: Xd, Xn: Xn, immr: lsb, imms: lsb + width - 1)
    }

    // C6.2.432
    public static func SXTB(
        Wd: UInt8, Wn: UInt8
    ) -> Self {
        return SBFM(Wd: Wd, Wn: Wn, immr: 0, imms: 7)
    }

    // C6.2.432
    public static func SXTB(
        Xd: UInt8, Wn: UInt8
    ) -> Self {
        return SBFM(Xd: Xd, Xn: Wn, immr: 0, imms: 7)
    }

    // C6.2.433
    public static func SXTH(
        Wd: UInt8, Wn: UInt8
    ) -> Self {
        return SBFM(Wd: Wd, Wn: Wn, immr: 0, imms: 15)
    }

    // C6.2.433
    public static func SXTH(
        Xd: UInt8, Wn: UInt8
    ) -> Self {
        return SBFM(Xd: Xd, Xn: Wn, immr: 0, imms: 15)
    }

    // C6.2.434
    public static func SXTW(
        Xd: UInt8, Wn: UInt8
    ) -> Self {
        return SBFM(Xd: Xd, Xn: Wn, immr: 0, imms: 31)
    }

    // C6.2.38
    public static func BFM(
        Wd: UInt8, Wn: UInt8, immr: UInt8, imms: UInt8
    ) -> Self {
        return Self(
            encoded: encodeBitfieldImmediateInstruction(
                sf: false,
                opc: 0b01,
                N: false,
                immr: immr & 0b111111,
                imms: imms & 0b111111,
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.38
    public static func BFM(
        Xd: UInt8, Xn: UInt8, immr: UInt8, imms: UInt8
    ) -> Self {
        return Self(
            encoded: encodeBitfieldImmediateInstruction(
                sf: true,
                opc: 0b01,
                N: true,
                immr: immr & 0b111111,
                imms: imms & 0b111111,
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.36
    /// - Warning: This requires at least ARMv8.2.
    public static func BFC(
        Wd: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return BFM(Wd: Wd, Wn: 0b11111, immr: UInt8(-Int8(lsb) % 32), imms: width - 1)
    }

    // C6.2.36
    /// - Warning: This requires at least ARMv8.2.
    public static func BFC(
        Xd: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return BFM(Xd: Xd, Xn: 0b11111, immr: UInt8(-Int8(lsb) % 64), imms: width - 1)
    }

    // C6.2.37
    public static func BFI(
        Wd: UInt8, Wn: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return BFM(Wd: Wd, Wn: Wn, immr: UInt8(-Int8(lsb) % 32), imms: width - 1)
    }

    // C6.2.37
    public static func BFI(
        Xd: UInt8, Xn: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return BFM(Xd: Xd, Xn: Xn, immr: UInt8(-Int8(lsb) % 64), imms: width - 1)
    }

    // C6.2.39
    public static func BFXIL(
        Wd: UInt8, Wn: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return BFM(Wd: Wd, Wn: Wn, immr: lsb, imms: lsb + width - 1)
    }

    // C6.2.39
    public static func BFXIL(
        Xd: UInt8, Xn: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return BFM(Xd: Xd, Xn: Xn, immr: lsb, imms: lsb + width - 1)
    }

    // C6.2.451
    public static func UBFM(
        Wd: UInt8, Wn: UInt8, immr: UInt8, imms: UInt8
    ) -> Self {
        return Self(
            encoded: encodeBitfieldImmediateInstruction(
                sf: false,
                opc: 0b10,
                N: false,
                immr: immr & 0b111111,
                imms: imms & 0b111111,
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C6.2.451
    public static func UBFM(
        Xd: UInt8, Xn: UInt8, immr: UInt8, imms: UInt8
    ) -> Self {
        return Self(
            encoded: encodeBitfieldImmediateInstruction(
                sf: true,
                opc: 0b10,
                N: true,
                immr: immr & 0b111111,
                imms: imms & 0b111111,
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.238
    public static func LSL(
        Wd: UInt8, Wn: UInt8, shift: UInt8
    ) -> Self {
        return UBFM(Wd: Wd, Wn: Wn, immr: UInt8(-Int8(shift) % 32), imms: 31 - shift)
    }

    // C6.2.238
    public static func LSL(
        Xd: UInt8, Xn: UInt8, shift: UInt8
    ) -> Self {
        return UBFM(Xd: Xd, Xn: Xn, immr: UInt8(-Int8(shift) % 64), imms: 63 - shift)
    }

    // C6.2.241
    public static func LSR(
        Wd: UInt8, Wn: UInt8, shift: UInt8
    ) -> Self {
        return UBFM(Wd: Wd, Wn: Wn, immr: shift, imms: 31)
    }

    // C6.2.241
    public static func LSR(
        Xd: UInt8, Xn: UInt8, shift: UInt8
    ) -> Self {
        return UBFM(Xd: Xd, Xn: Xn, immr: shift, imms: 63)
    }

    // C6.2.450
    public static func UBFIZ(
        Wd: UInt8, Wn: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return UBFM(Wd: Wd, Wn: Wn, immr: UInt8(-Int8(lsb) % 32), imms: width - 1)
    }

    // C6.2.450
    public static func UBFIZ(
        Xd: UInt8, Xn: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return UBFM(Xd: Xd, Xn: Xn, immr: UInt8(-Int8(lsb) % 64), imms: width - 1)
    }

    // C6.2.452
    public static func UBFX(
        Wd: UInt8, Wn: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return UBFM(Wd: Wd, Wn: Wn, immr: lsb, imms: lsb + width - 1)
    }

    // C6.2.452
    public static func UBFX(
        Xd: UInt8, Xn: UInt8, lsb: UInt8, width: UInt8
    ) -> Self {
        return UBFM(Xd: Xd, Xn: Xn, immr: lsb, imms: lsb + width - 1)
    }

    // C6.2.464
    public static func UXTB(
        Wd: UInt8, Wn: UInt8
    ) -> Self {
        return UBFM(Wd: Wd, Wn: Wn, immr: 0, imms: 7)
    }

    // C6.2.465
    public static func UXTH(
        Wd: UInt8, Wn: UInt8
    ) -> Self {
        return UBFM(Wd: Wd, Wn: Wn, immr: 0, imms: 15)
    }
}

// MARK: DPI | Extract

extension A64InstructionSet.Instruction {
    // C4.1.93.9
    private static func encodeExtractImmediateInstruction(
        sf: Bool,
        op21: UInt8,
        N: Bool,
        o0: Bool,
        Rm: UInt8,
        imms: UInt8,
        Rn: UInt8,
        Rd: UInt8
    ) -> UInt32 {
        return encodeDataProcessingImmediateInstruction(
            op0: 0b11,
            op1: 0b1110,  // Technically 0b111x as the last bit depends on the additional segments.
            additional: [
                (sf ? 1 : 0, length: 1, shift: 31),
                (op21, length: 2, shift: 29),
                (N ? 1 : 0, length: 1, shift: 22),
                (o0 ? 1 : 0, length: 1, shift: 21),
                (Rm, length: 5, shift: 16),
                (imms, length: 6, shift: 10),
                (Rn, length: 5, shift: 5),
                (Rd, length: 5, shift: 0),
            ]
        )
    }

    // C4.1.93.9
    public static func EXTR(
        Wd: UInt8, Wn: UInt8, Wm: UInt8, lsb: UInt8
    ) -> Self {
        return Self(
            encoded: encodeExtractImmediateInstruction(
                sf: false,
                op21: 0b00,
                N: false,
                o0: false,
                Rm: Wm & 0b11111,
                imms: lsb,
                Rn: Wn,
                Rd: Wd
            )
        )
    }

    // C4.1.93.9
    public static func EXTR(
        Xd: UInt8, Xn: UInt8, Xm: UInt8, lsb: UInt8
    ) -> Self {
        return Self(
            encoded: encodeExtractImmediateInstruction(
                sf: true,
                op21: 0b00,
                N: true,
                o0: false,
                Rm: Xm & 0b11111,
                imms: lsb,
                Rn: Xn,
                Rd: Xd
            )
        )
    }

    // C6.2.316
    public static func ROR(
        Wd: UInt8, Ws: UInt8, shift: UInt8
    ) -> Self {
        return EXTR(Wd: Wd, Wn: Ws, Wm: Ws, lsb: shift)
    }

    // C6.2.316
    public static func ROR(
        Xd: UInt8, Xs: UInt8, shift: UInt8
    ) -> Self {
        return EXTR(Xd: Xd, Xn: Xs, Xm: Xs, lsb: shift)
    }
}

// MARK: IS | Branch/Excp/System

extension A64InstructionSet.Instruction {
    // C4.1.94
    private static func encodeBESInstruction(
        op0: UInt8,
        op1: UInt16,
        op2: UInt8,
        additional: [Segment] = []
    ) -> UInt32 {
        return encodedInstruction(
            op0: 0b0,  // Technically 0bx as the bit depends on the additional segments.
            op1: 0b1010,  // Technically 0b101x as the last bit depends on the additional segments.
            additional: [
                (op0, length: 3, shift: 29),
                (op1, length: 14, shift: 12),
                (op2, length: 5, shift: 0),
            ] + additional
        )
    }
}

// MARK: BES | Conditional Branch

extension A64InstructionSet.Instruction {
    // C4.1.94.1
    public static func encodeConditionalBranchInstruction(
        imm19: Int32,
        op0: UInt8,
        cond: UInt8
    ) -> UInt32 {
        return encodeBESInstruction(
            op0: 0b010,
            op1: 0b000000_00000000,  // Technically 0b00xxxxxxxxxxxx as the last several bits depend on the additional segments.
            op2: 0,  // Depends on the additional segments.
            additional: [
                (imm19, length: 19, shift: 5),
                (op0, length: 1, shift: 4),
                (cond, length: 4, shift: 0),
            ]
        )
    }

    // C6.2.34, C6.2.35
    public enum BranchCondition: UInt8 {
        case EQ = 0b0000
        case NE = 0b0001
        case CS = 0b0010
        case CC = 0b0011
        case MI = 0b0100
        case PL = 0b0101
        case VS = 0b0110
        case VC = 0b0111
        case HI = 0b1000
        case LS = 0b1001
        case GE = 0b1010
        case LT = 0b1011
        case GT = 0b1100
        case LE = 0b1101
        case AL = 0b1110
        case NV = 0b1111
    }

    // C6.2.34
    public static func B(
        cond: BranchCondition,
        label: Int32
    ) -> Self {
        return Self(
            encoded: encodeConditionalBranchInstruction(
                imm19: label >> 2,
                op0: 0b0,
                cond: cond.rawValue
            )
        )
    }

    // C6.2.35
    /// - Warning: This requires the Hinted conditional branches (HCB) feature.
    public static func BC(
        cond: BranchCondition,
        label: Int32
    ) -> Self {
        return Self(
            encoded: encodeConditionalBranchInstruction(
                imm19: label >> 2,
                op0: 0b1,
                cond: cond.rawValue
            )
        )
    }
}

// TODO: Implement the other BES instructions.

// MARK: BES | Unc. Branch (reg)

extension A64InstructionSet.Instruction {
    // C4.1.94.13
    private static func encodeUnconditionalBranchRegisterInstruction(
        opc: UInt8,
        op2: UInt8,
        op3: UInt8,
        Rn: UInt8,
        op4: UInt8
    ) -> UInt32 {
        return encodeBESInstruction(
            op0: 0b110,
            op1: 0b100000_00000000,  // Technically 0b1xxxxxxxxxxxxx as the last several bits depend on the additional segments.
            op2: 0,  // Depends on the additional segments.
            additional: [
                (opc, length: 4, shift: 21),
                (op2, length: 5, shift: 16),
                (op3, length: 6, shift: 10),
                (Rn, length: 5, shift: 5),
                (op4, length: 5, shift: 0),
            ]
        )
    }

    // C6.2.45
    public static func BR(
        Xn: UInt8
    ) -> Self {
        return Self(
            encoded: encodeUnconditionalBranchRegisterInstruction(
                opc: 0b0000,
                op2: 0b11111,
                op3: 0b000000,
                Rn: Xn,
                op4: 0b0000
            )
        )
    }

    // C6.2.43
    public static func BLR(
        Xn: UInt8
    ) -> Self {
        return Self(
            encoded: encodeUnconditionalBranchRegisterInstruction(
                opc: 0b0001,
                op2: 0b11111,
                op3: 0b000000,
                Rn: Xn,
                op4: 0b0000
            )
        )
    }
}

// MARK: BES | Unc. Branch (imm)

extension A64InstructionSet.Instruction {
    // C4.1.94.14
    public static func encodeUnconditionalBranchImmediateInstruction(
        op: UInt8,
        imm26: Int32
    ) -> UInt32 {
        return encodeBESInstruction(
            op0: 0b000,  // Technically 0bx00 as the first bit depends on the additional segments.
            op1: 0,  // Depends on the additional segments.
            op2: 0,  // Depends on the additional segments.
            additional: [
                (op, length: 1, shift: 31),
                (imm26, length: 26, shift: 0),
            ]
        )
    }

    // C6.2.33
    public static func B(
        label: Int32
    ) -> Self {
        return Self(
            encoded: encodeUnconditionalBranchImmediateInstruction(
                op: 0b0,
                imm26: label >> 2
            )
        )
    }

    // C6.2.42
    public static func BL(
        label: Int32
    ) -> Self {
        return Self(
            encoded: encodeUnconditionalBranchImmediateInstruction(
                op: 0b1,
                imm26: label >> 2
            )
        )
    }
}

// TODO: Implement the other instructions.
