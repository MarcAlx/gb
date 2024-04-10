import XCTest
@testable import GBKit

final class IOSTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_lcdstat() throws {
        let ios:IOInterface = IOInterface.sharedInstance
        ios.reset()
        
        ios.setLCDStatFlag(.HBlankInterruptSource, enabled: true)
        XCTAssertTrue(ios.readLCDStatFlag(.HBlankInterruptSource))
        XCTAssertFalse(ios.readLCDStatFlag(.LYCeqLYInterruptSource))
        XCTAssertFalse(ios.readLCDStatFlag(.OAMInterruptSource))
        XCTAssertFalse(ios.readLCDStatFlag(.VBlankInterruptSource))
        ios.setLCDStatFlag(.HBlankInterruptSource, enabled: false)
        
        ios.setLCDStatFlag(.VBlankInterruptSource, enabled: true)
        XCTAssertTrue(ios.readLCDStatFlag(.VBlankInterruptSource))
        XCTAssertFalse(ios.readLCDStatFlag(.LYCeqLYInterruptSource))
        XCTAssertFalse(ios.readLCDStatFlag(.OAMInterruptSource))
        XCTAssertFalse(ios.readLCDStatFlag(.HBlankInterruptSource))
        ios.setLCDStatFlag(.VBlankInterruptSource, enabled: false)
        
        ios.setLCDStatFlag(.LYCeqLYInterruptSource, enabled: true)
        XCTAssertTrue(ios.readLCDStatFlag(.LYCeqLYInterruptSource))
        XCTAssertFalse(ios.readLCDStatFlag(.HBlankInterruptSource))
        XCTAssertFalse(ios.readLCDStatFlag(.OAMInterruptSource))
        XCTAssertFalse(ios.readLCDStatFlag(.VBlankInterruptSource))
        ios.setLCDStatFlag(.LYCeqLYInterruptSource, enabled: false)
        
        ios.setLCDStatFlag(.OAMInterruptSource, enabled: true)
        XCTAssertTrue(ios.readLCDStatFlag(.OAMInterruptSource))
        XCTAssertFalse(ios.readLCDStatFlag(.LYCeqLYInterruptSource))
        XCTAssertFalse(ios.readLCDStatFlag(.HBlankInterruptSource))
        XCTAssertFalse(ios.readLCDStatFlag(.VBlankInterruptSource))
        ios.setLCDStatFlag(.OAMInterruptSource, enabled: false)
    }
}
