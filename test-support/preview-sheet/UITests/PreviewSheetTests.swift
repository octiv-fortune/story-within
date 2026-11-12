import XCTest

final class PreviewSheetTests: XCTestCase {
    @MainActor func testFirstReviewTapRendersCommunityPreview() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        let story = app.buttons.containing(.staticText, identifier: "Preview Regression — Goat").firstMatch
        XCTAssertTrue(story.waitForExistence(timeout: 5), "Disposable private saved story must be present")
        story.tap()
        let review = app.buttons["Review for local community preview"]
        for _ in 0..<8 {
            if review.exists && review.isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(review.exists && review.isHittable, "Saved private story must expose Review")
        review.tap()
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "First preview presentation"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        XCTAssertTrue(app.staticTexts["Review what will be visible"].waitForExistence(timeout: 3), "First Review tap must render preview content, rather than an empty sheet")
        XCTAssertTrue(app.buttons["Cancel"].exists, "Preview must offer cancellation on first presentation")
        app.buttons["Cancel"].tap()
        XCTAssertTrue(review.waitForExistence(timeout: 3) && review.isHittable, "Cancelling must return to the private story review")
        review.tap()
        XCTAssertTrue(app.staticTexts["Review what will be visible"].waitForExistence(timeout: 3), "Reopening after cancellation must render the preview content")
        XCTAssertTrue(app.buttons["Cancel"].exists, "Reopened preview must offer cancellation")
        app.buttons["Cancel"].tap()
        XCTAssertTrue(review.waitForExistence(timeout: 3) && review.isHittable, "Cancelling again must leave the private review available")
    }
}
