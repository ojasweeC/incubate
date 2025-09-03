//
//  IncubateUITestsLaunchTests.swift
//  IncubateUITests
//
//  Created by Xcode on 2024-01-01.
//

import XCTest

final class IncubateUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert assertions here to log the state of the app such as the elements that are displayed, accessibility identifiers, and other state information that might be helpful for debugging.
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
