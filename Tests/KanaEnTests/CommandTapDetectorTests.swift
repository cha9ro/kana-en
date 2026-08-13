import XCTest
@testable import KanaEn

final class CommandTapDetectorTests: XCTestCase {
    func testLeftCommandPressedAlone() {
        var detector = CommandTapDetector()
        XCTAssertNil(detector.process(.commandDown(.left)))
        XCTAssertEqual(detector.process(.commandUp(.left)), .left)
    }

    func testRightCommandPressedAlone() {
        var detector = CommandTapDetector()
        XCTAssertNil(detector.process(.commandDown(.right)))
        XCTAssertEqual(detector.process(.commandUp(.right)), .right)
    }

    func testCommandShortcutIsIgnored() {
        var detector = CommandTapDetector()
        XCTAssertNil(detector.process(.commandDown(.left)))
        XCTAssertNil(detector.process(.otherActivity))
        XCTAssertNil(detector.process(.commandUp(.left)))
    }

    func testPressingBothCommandsIsIgnored() {
        var detector = CommandTapDetector()
        XCTAssertNil(detector.process(.commandDown(.left)))
        XCTAssertNil(detector.process(.commandDown(.right)))
        XCTAssertNil(detector.process(.commandUp(.right)))
        XCTAssertNil(detector.process(.commandUp(.left)))
    }

    func testMismatchedReleaseIsIgnored() {
        var detector = CommandTapDetector()
        XCTAssertNil(detector.process(.commandDown(.left)))
        XCTAssertNil(detector.process(.commandUp(.right)))
    }
}
