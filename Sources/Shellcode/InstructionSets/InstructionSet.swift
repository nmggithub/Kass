public protocol Instruction: RawRepresentable, ExpressibleByArrayLiteral, ShellcodeRepresentable
where RawValue == [UInt8], ArrayLiteralElement == UInt8 {
    typealias Segment = (any BinaryInteger, length: Int, shift: Int)
    static func encode(segments: [Segment]) -> EncodedForm
    associatedtype EncodedForm: UnsignedInteger
    init(rawValue: [UInt8])
    init(encoded: EncodedForm)
}

extension Instruction {
    /// Initializes an instruction with raw bytes.
    public init(arrayLiteral elements: UInt8...) {
        self.init(rawValue: elements)
    }

    /// The raw shellcode for the instruction.
    public var shellcode: [UInt8] {
        rawValue
    }

    // This is used because the type checker struggles with complex bitwise operations.
    public static func encode(segments: [Segment]) -> EncodedForm {
        return segments.reduce(0) { currentValue, segment in
            // We convert the segments to EncodedForm first, so that we don't lose any bits when shifting.
            let incoming = EncodedForm(segment.0.magnitude)
            let mask = EncodedForm(1 << segment.length) - 1
            // We mask the incoming value to ensure it we only take the bits we want.
            let value = incoming & mask
            // We calculate the two's complement of the value if it is negative.
            let signedValue = (Int(segment.0) < 0 ? ((value ^ mask) + 1) & mask : value)
            // Finally, we shift the value to the correct position and combine it with the current value.
            let shifted = signedValue << segment.shift
            return currentValue | shifted
        }
    }
}

public protocol InstructionSet {
    /// The type for an instruction in the instruction set.
    associatedtype Instruction: Shellcode.Instruction
}

extension Array: ShellcodeRepresentable where Element: ShellcodeRepresentable {
    /// The raw shellcode.
    public var shellcode: [UInt8] {
        reduce(into: []) { result, instruction in
            result.append(contentsOf: instruction.shellcode)
        }
    }
}
