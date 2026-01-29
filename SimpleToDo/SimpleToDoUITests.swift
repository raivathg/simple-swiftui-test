import XCTest

final class SimpleToDoUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Put the app in a deterministic test mode if you support launch arguments:
        app.launchArguments += ["-uiTesting", "-resetData"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testAddTodoAndAttachScreenshot() throws {
        // Wait for the main view to appear. Adjust label/text if the sample app uses a different title.
        let exists = NSPredicate(format: "exists == true")

        // Example: look for a list or navigation title - adjust to the app
        let navTitle = app.navigationBars.element(boundBy: 0)
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Main view did not appear")

        // Try tapping a button that adds a new todo.
        // Many sample todo apps use a "+" bar button; try multiple selectors.
        let addButtonCandidates = [
            app.buttons["Add"],            // accessibility label "Add"
            app.buttons["+"],              // + button with label +
            app.buttons["addButton"],      // possible accessibilityIdentifier
            app.navigationBars.buttons["Add"],
            app.navigationBars.buttons["+"]
        ]

        var tapped = false
        for btn in addButtonCandidates {
            if btn.exists {
                btn.tap()
                tapped = true
                break
            }
        }

        // If we didn't find an add button by label, attempt tapping a toolbar button at index 0
        if !tapped, app.toolbars.buttons.count > 0 {
            app.toolbars.buttons.element(boundBy: 0).tap()
            tapped = true
        }

        // Now try to enter a todo text (adjust element identifiers if needed)
        // Search for a text field (common in many simple todo UIs)
        if let textField = app.textFields.firstMatch, textField.exists {
            _ = textField.waitForExistence(timeout: 3)
            textField.tap()
            textField.typeText("Buy milk")
            // Submit — many apps use "Add" or "Return" to submit
            app.buttons["Done"].tap() // try Done
            app.keyboards.buttons["return"].tap() // fallback
        } else {
            // Some apps use alerts or sheets for input: handle generic sheet text field
            let sheetTextField = app.sheets.textFields.firstMatch
            if sheetTextField.exists {
                sheetTextField.tap()
                sheetTextField.typeText("Buy milk")
                app.buttons["Add"].tap()
            } else {
                // If we can't find an input, still take a screenshot to debug
            }
        }

        // Small wait for UI to update
        sleep(1)

        // Assert that the new todo text appears somewhere in the UI
        let newItem = app.staticTexts["Buy milk"]
        XCTAssertTrue(newItem.waitForExistence(timeout: 5), "Added todo did not appear")

        // Attach a screenshot for the test report (keeps always)
        let screenshot = XCUIScreen.main.screenshot()
        let attach = XCTAttachment(screenshot: screenshot)
        attach.name = "Todo list after add"
        attach.lifetime = .keepAlways
        add(attach)
    }
}
