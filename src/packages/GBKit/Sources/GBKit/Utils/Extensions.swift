import Foundation

extension Data {
    /**
     * Converts Data to a byte array
     */
    func toArray() -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: self.count)
        self.copyBytes(to: &buffer, count: self.count)
        return buffer
    }
}

extension UInt8 {
    /**
     * Converts an UInt8 to its Hex string representation
     */
    func toHexString() -> String {
        return String(self, radix: 8, uppercase: true)
    }
}
