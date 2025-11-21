import Foundation

extension Mach {
    /// The C representation of a name string.
    public typealias CNameString = (
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar
    )
}

func cNameStringToString(
    _ nameTuple: Mach.CNameString
) -> String {
    let nameData = Data(
        bytes: [
            nameTuple.0, nameTuple.1, nameTuple.2, nameTuple.3,
            nameTuple.4, nameTuple.5, nameTuple.6, nameTuple.7,
            nameTuple.8, nameTuple.9, nameTuple.10, nameTuple.11,
            nameTuple.12, nameTuple.13, nameTuple.14, nameTuple.15,
        ],
        count: 16
    )
    if let nameString = String(data: nameData, encoding: .utf8) {
        return nameString.trimmingCharacters(in: .controlCharacters.union(.whitespaces))
    } else {
        return ""
    }
}
