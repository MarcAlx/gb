import XCTest
@testable import GBKit

final class ArithmeticsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_fit() {
        XCTAssertTrue(fit(600) == Byte.max)
    }
}
