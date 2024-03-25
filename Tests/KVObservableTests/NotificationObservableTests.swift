@testable import KVObservable
import XCTest

final class NotificationObservableTests: XCTestCase {
  func testNotificationObservableReceivesNotification() {
    let expectation = self.expectation(description: "NotificationObservable should receive notification")
    let notificationName = Notification.Name("TestNotification")
    var didReceiveNotification = false

    let observable = NotificationObservable(name: notificationName) { _ in
      didReceiveNotification = true
      expectation.fulfill()
    }

    // turn off the warning for unused variable
    _ = observable

    NotificationCenter.default.post(name: notificationName, object: nil)

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Notification was not received")
      XCTAssertTrue(didReceiveNotification, "NotificationObservable did not receive the notification")
    }
  }

  func testNotificationObservablePauseResume() {
    let notificationName = Notification.Name("TestNotification")
    var notificationCount = 0

    let observable = NotificationObservable(name: notificationName) { _ in
      notificationCount += 1
    }

    NotificationCenter.default.post(name: notificationName, object: nil)
    XCTAssertEqual(notificationCount, 1, "NotificationObservable should have received 1 notification")

    observable.pause()
    NotificationCenter.default.post(name: notificationName, object: nil)
    XCTAssertEqual(notificationCount, 1, "NotificationObservable should not receive notifications when paused")

    observable.resume()
    NotificationCenter.default.post(name: notificationName, object: nil)
    XCTAssertEqual(notificationCount, 2, "NotificationObservable should resume receiving notifications")
  }

  func testNotificationObservableDeinit() {
    let expectation = self.expectation(description: "NotificationObservable should stop receiving notifications on deinit")
    expectation.isInverted = true
    let notificationName = Notification.Name("TestNotification")

    var observable: NotificationObservable? = NotificationObservable(name: notificationName) { _ in
      expectation.fulfill()
    }

    observable = nil

    // turn off the warning for unread variable
    _ = observable

    NotificationCenter.default.post(name: notificationName, object: nil)

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "NotificationObservable did not deinitialize correctly")
    }
  }

  func testNotificationObservableReceivesNotificationWithObject() {
    let expectation = self.expectation(description: "NotificationObservable should receive notification with specific object")
    let notificationName = Notification.Name("TestNotificationWithObject")
    let notificationObject = "TestObject"
    var didReceiveNotificationForObject = false

    let observable = NotificationObservable(name: notificationName) { notification in
      if let object = notification.object as? String, object == notificationObject {
        didReceiveNotificationForObject = true
      }
      expectation.fulfill()
    }

    // turn off the warning for unused variable
    _ = observable

    NotificationCenter.default.post(name: notificationName, object: notificationObject)

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Notification with object was not received")
      XCTAssertTrue(didReceiveNotificationForObject, "NotificationObservable did not receive the notification with the expected object")
    }
  }

  func testNotificationObservableReceivesNotificationFromCorrectObject() {
    let expectation = self.expectation(description: "NotificationObservable should receive notification from correct object")
    let notificationName = Notification.Name("TestNotificationForObject")
    let correctObject = "CorrectObject"
    var didReceiveNotificationFromCorrectObject = false

    let observable = NotificationObservable(name: notificationName, object: correctObject) { notification in
      if let object = notification.object as? String, object == correctObject {
        didReceiveNotificationFromCorrectObject = true
        expectation.fulfill()
      }
    }

    // turn off the warning for unused variable
    _ = observable

    // Post notification with the correct object
    NotificationCenter.default.post(name: notificationName, object: correctObject)

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Notification from correct object was not received correctly")
      XCTAssertTrue(didReceiveNotificationFromCorrectObject, "NotificationObservable did not receive the notification from the correct object")
    }
  }

  func testNotificationObservableDoesNotReceiveNotificationFromIncorrectObject() {
    let expectation = self.expectation(description: "NotificationObservable should not receive notification from incorrect object")
    expectation.isInverted = true // Expectation is inverted to ensure that the observable does not receive the notification
    let notificationName = Notification.Name("TestNotificationForObject")
    let correctObject = 1
    let incorrectObject = "IncorrectObject"

    let observable = NotificationObservable(name: notificationName, object: correctObject) { _ in
      expectation.fulfill()
    }

    // turn off the warning for unused variable
    _ = observable

    // Post notification with an incorrect object, which should not trigger the observable
    NotificationCenter.default.post(name: notificationName, object: incorrectObject)

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Notification from incorrect object was incorrectly received")
    }
  }

  func testNotificationObservableReceivesNotificationWithUserInfo() {
    let expectation = self.expectation(description: "NotificationObservable should receive notification with userInfo")
    let notificationName = Notification.Name("TestNotificationWithUserInfo")
    let userInfoKey = "TestKey"
    let userInfoValue = "TestValue"
    var didReceiveNotificationWithUserInfo = false

    let observable = NotificationObservable(name: notificationName) { notification in
      if let userInfo = notification.userInfo as? [String: String], userInfo[userInfoKey] == userInfoValue {
        didReceiveNotificationWithUserInfo = true
      }
      expectation.fulfill()
    }

    // turn off the warning for unused variable
    _ = observable

    NotificationCenter.default.post(name: notificationName, object: nil, userInfo: [userInfoKey: userInfoValue])

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Notification with userInfo was not received")
      XCTAssertTrue(didReceiveNotificationWithUserInfo, "NotificationObservable did not receive the notification with the expected userInfo")
    }
  }
}
