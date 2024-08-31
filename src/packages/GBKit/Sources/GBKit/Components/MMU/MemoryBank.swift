/// a memory bank
class MemoryBank:Component {
    /// bank data
    private var _data:[Byte]
    private var _name:String
    
    /// allow data extraction from range
    public subscript(range:ClosedRange<Int>) -> ArraySlice<Byte> {
        get {
            return self._data[range]
        }
        set {
            self._data[range] = newValue
        }
    }
    
    /// subscript to ease data access
    public subscript(index:Short) -> Byte {
        get {
            return self._data[Int(index)]
        }
        set {
            self._data[Int(index)] = newValue
        }
    }
    
    /// init with values
    public init(data:[Byte]) {
        self._data = data
        self._name = ""
    }
    
    /// init with size
    public init(size:Int, name:String = "") {
        self._data = Array(repeating: 0, count: size)
        self._name = name
    }
    
    public func load(bank:MemoryBank,at:Int) {
        for i in 0..<bank._data.count {
            self._data[at+i] = bank[Short(i)]
        }
    }
    
    /// clears all data
    public func reset() {
        //fill data with 0 while keeping same size
        self._data = Array(repeating: 0, count: self._data.count)
    }
}
