@testable import KVObservable
import XCTest
import Combine

final class KVOPublisherTests: XCTestCase {
  class TestObject: NSObject {
    @objc dynamic var value: Int = 0
  }

  var cancellables: Set<AnyCancellable>!

  override func setUp() {
    super.setUp()
    cancellables = []
  }

  override func tearDown() {
    cancellables?.forEach { $0.cancel() }
    cancellables = nil
    super.tearDown()
  }

  func testPublishing() {
    let expectation = self.expectation(description: "Value should change")
    let testObject = TestObject()
    let publisher = KVOPublisher(object: testObject, keyPath: \TestObject.value)

    publisher.value.sink { newValue in
      XCTAssertEqual(newValue, 10)
      expectation.fulfill()
    }.store(in: &cancellables)

    testObject.value = 10

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Publishing value changes did not work as expected")
    }
  }

  func testPause() {
    let pauseExpectation = expectation(description: "Value should not change after pause")
    pauseExpectation.isInverted = true // We expect this not to fulfill

    let testObject = TestObject()
    let publisher = KVOPublisher(object: testObject, keyPath: \TestObject.value)

    publisher.value.sink { _ in
      pauseExpectation.fulfill()
    }.store(in: &cancellables)

    // Pause the observation to ensure it's not observing changes
    publisher.pause()
    testObject.value = 10

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Observation was not paused correctly")
    }
  }

  func testResume() {
    let resumeExpectation = expectation(description: "Value should change after resume")

    let testObject = TestObject()
    let publisher = KVOPublisher(object: testObject, keyPath: \TestObject.value)

    publisher.value.sink { newValue in
      XCTAssertEqual(newValue, 20)
      resumeExpectation.fulfill()
    }.store(in: &cancellables)

    // Pause observation to ensure it's not observing changes
    publisher.pause()
    testObject.value = 10

    // Resume observation and change the value to test if it observes the change
    publisher.resume()
    testObject.value = 20

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Observation did not resume correctly")
    }
  }

  func testDeinit() {
    let expectation = self.expectation(description: "Value should not change after deinit")
    expectation.isInverted = true // We expect this not to fulfill

    var testObject: TestObject? = TestObject()
    var publisher: KVOPublisher<TestObject, Int>? = KVOPublisher(object: testObject!, keyPath: \TestObject.value)

    publisher?.value.sink { _ in
      expectation.fulfill()
    }.store(in: &cancellables)

    // Trigger deinit by setting the publisher to nil
    publisher = nil

    // Attempt to change the value after the publisher is set to nil
    testObject?.value = 10

    // Clean up
    testObject = nil

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Publisher did not deinit correctly")
    }
  }
}
