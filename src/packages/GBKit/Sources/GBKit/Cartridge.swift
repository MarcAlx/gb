import Foundation

public class Cartridge: Describable {
    
    private var source:Data = Data()
    private var _data:[Byte] = []
    var data:[Byte] {
        get {
            return self._data
        }
    }
    
    var banks:[MemoryBank] = []
    
    ///headers of the cartridge read from ROM
    public private(set) var headers:CartridgeHeader = CartridgeHeader()
    
    public init() {}
    
    ///init cartridge from ROM data
    public init(data:Data) throws {
        self.source = data
        self._data = self.source.toArray()
        self.headers = try CartridgeHeader(cartridgeData: self._data)
        self.initBanks()
    }
    
    /// init banks from data
    private func initBanks() {
        for i in 0..<self.headers.nbBankInROM {
            let from = i * GBConstants.ROMBankSizeInBytes
            let to   = (i+1) * GBConstants.ROMBankSizeInBytes
            self.banks.append(MemoryBank(data:Array(self.data[from..<to])))
        }
    }
    
    public func describe() -> String {
        return """
        Title: \(self.headers.title)
        Manufacturer code: \(self.headers.manufacturerCode ?? "")
        Licensee: \(self.headers.licensee ?? "unknown")
        Destination: \(String(reflecting: self.headers.destination))
        Version: \(self.headers.versionNumber)
        
        Cartridge type: \(String(reflecting: self.headers.cartridgeType))
        ROM: \(self.headers.romSize)KiB (\(self.headers.nbBankInROM) banks)
        RAM: \(self.headers.ramSize)KiB (\(self.headers.nbBankInRAM) banks)
        CGB support: \(self.headers.cgbFlag != nil ? String(reflecting: self.headers.cgbFlag) : "unspecified" )
        
        Nintendo logo in headers: \(self.headers.isNintendoLogoPresent)
        
        Header checksum: \(self.headers.headerChecksum) (computed: \(self.headers.headerChecksumComputed), equals: \(self.headers.headerChecksum==self.headers.headerChecksumComputed))
        Global checksum: \(self.headers.checksum) (computed: \(self.headers.checksumComputed), equals: \(self.headers.checksum==self.headers.checksumComputed))
        """
    }
}
