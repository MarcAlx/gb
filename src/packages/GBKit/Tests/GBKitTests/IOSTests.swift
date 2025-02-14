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
        let ios:IOInterface = MMU()
        
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
    
    func test_lcdcontrol() throws {
        let mmu:MMU = MMU()
        let ios:IOInterface = mmu
        
        mmu[IOAddresses.LCD_CONTROL.rawValue] = 0x0
        ios.setLCDControlFlag(.BG_AND_WINDOW_ENABLE, enabled: true)
        XCTAssertTrue(ios.readLCDControlFlag(.BG_AND_WINDOW_ENABLE))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0000_0001)
        ios.setLCDControlFlag(.BG_AND_WINDOW_ENABLE, enabled: false)
        XCTAssertFalse(ios.readLCDControlFlag(.BG_AND_WINDOW_ENABLE))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0000_0000)
        
        mmu[IOAddresses.LCD_CONTROL.rawValue] = 0x0
        ios.setLCDControlFlag(.OBJ_ENABLE, enabled: true)
        XCTAssertTrue(ios.readLCDControlFlag(.OBJ_ENABLE))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0000_0010)
        ios.setLCDControlFlag(.OBJ_ENABLE, enabled: false)
        XCTAssertFalse(ios.readLCDControlFlag(.OBJ_ENABLE))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0000_0000)
        
        mmu[IOAddresses.LCD_CONTROL.rawValue] = 0x0
        ios.setLCDControlFlag(.OBJ_SIZE, enabled: true)
        XCTAssertTrue(ios.readLCDControlFlag(.OBJ_SIZE))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0000_0100)
        ios.setLCDControlFlag(.OBJ_SIZE, enabled: false)
        XCTAssertFalse(ios.readLCDControlFlag(.OBJ_SIZE))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0000_0000)
        
        mmu[IOAddresses.LCD_CONTROL.rawValue] = 0x0
        ios.setLCDControlFlag(.BG_TILE_MAP_AREA, enabled: true)
        XCTAssertTrue(ios.readLCDControlFlag(.BG_TILE_MAP_AREA))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0000_1000)
        ios.setLCDControlFlag(.BG_TILE_MAP_AREA, enabled: false)
        XCTAssertFalse(ios.readLCDControlFlag(.BG_TILE_MAP_AREA))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0000_0000)
        
        mmu[IOAddresses.LCD_CONTROL.rawValue] = 0x0
        ios.setLCDControlFlag(.BG_AND_WINDOW_TILE_DATA_AREA, enabled: true)
        XCTAssertTrue(ios.readLCDControlFlag(.BG_AND_WINDOW_TILE_DATA_AREA))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0001_0000)
        ios.setLCDControlFlag(.BG_AND_WINDOW_TILE_DATA_AREA, enabled: false)
        XCTAssertFalse(ios.readLCDControlFlag(.BG_AND_WINDOW_TILE_DATA_AREA))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0000_0000)
        
        mmu[IOAddresses.LCD_CONTROL.rawValue] = 0x0
        ios.setLCDControlFlag(.WINDOW_ENABLE, enabled: true)
        XCTAssertTrue(ios.readLCDControlFlag(.WINDOW_ENABLE))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0010_0000)
        ios.setLCDControlFlag(.WINDOW_ENABLE, enabled: false)
        XCTAssertFalse(ios.readLCDControlFlag(.WINDOW_ENABLE))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0000_0000)
        
        mmu[IOAddresses.LCD_CONTROL.rawValue] = 0x0
        ios.setLCDControlFlag(.WINDOW_TILE_AREA, enabled: true)
        XCTAssertTrue(ios.readLCDControlFlag(.WINDOW_TILE_AREA))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0100_0000)
        ios.setLCDControlFlag(.WINDOW_TILE_AREA, enabled: false)
        XCTAssertFalse(ios.readLCDControlFlag(.WINDOW_TILE_AREA))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0000_0000)
        
        mmu[IOAddresses.LCD_CONTROL.rawValue] = 0x0
        ios.setLCDControlFlag(.LCD_AND_PPU_ENABLE, enabled: true)
        XCTAssertTrue(ios.readLCDControlFlag(.LCD_AND_PPU_ENABLE))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b1000_0000)
        ios.setLCDControlFlag(.LCD_AND_PPU_ENABLE, enabled: false)
        XCTAssertFalse(ios.readLCDControlFlag(.LCD_AND_PPU_ENABLE))
        XCTAssertTrue(mmu[IOAddresses.LCD_CONTROL.rawValue] == 0b0000_0000)
    }
}
