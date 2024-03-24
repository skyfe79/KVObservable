@testable import KVObservable
import XCTest

final class KVObservableTests: XCTestCase {
  class TestObject: NSObject {
    @objc dynamic var value: Int = 0
  }

  func testObservation() {
    let expectation = self.expectation(description: "Value should change")
    let testObject = TestObject()
    let observable = KVObservable(object: testObject, keyPath: \TestObject.value) { newValue in
      XCTAssertEqual(newValue, 10)
      expectation.fulfill()
    }

    // remove warning
    let _ = observable

    testObject.value = 10

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Observing value changes did not work as expected")
    }
  }

  func testPauseObservation() {
    let expectation = self.expectation(description: "Value should not change after pause")
    expectation.isInverted = true // We expect this not to fulfill

    let testObject = TestObject()
    let observable = KVObservable(object: testObject, keyPath: \.value) { _ in
      expectation.fulfill()
    }

    observable.pause()
    testObject.value = 10

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Observation was not paused correctly")
    }
  }

  func testResumeObservation() {
    let pauseExpectation = expectation(description: "Value should not change after pause")
    pauseExpectation.isInverted = true // We expect this not to fulfill

    let resumeExpectation = expectation(description: "Value should change after resume")

    let testObject = TestObject()
    let observable = KVObservable(object: testObject, keyPath: \TestObject.value) { newValue in
      XCTAssertEqual(newValue, 20)
      resumeExpectation.fulfill()
    }

    // First, pause the observation to ensure it's not observing changes
    observable.pause()
    testObject.value = 10

    // Then, resume observation and change the value to test if it observes the change
    observable.resume()
    testObject.value = 20

    waitForExpectations(timeout: 2) { error in
      XCTAssertNil(error, "Observation did not resume correctly")
    }
  }

  func testDeinit() {
    let expectation = self.expectation(description: "Value should not change after deinit")
    expectation.isInverted = true // We expect this not to fulfill

    var testObject: TestObject? = TestObject()
    var observable: KVObservable<TestObject, Int>? = KVObservable(object: testObject!, keyPath: \TestObject.value) { _ in
      expectation.fulfill()
    }

    // Trigger deinit by setting the observable to nil
    observable = nil

    // Attempt to change the value after the observable is set to nil
    testObject?.value = 10

    // Clean up
    testObject = nil

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Observable did not deinit correctly")
    }
  }
}
