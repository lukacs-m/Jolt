//
//  File.swift
//  
//
//  Created by Martin Lukacs on 01/10/2021.
//

import XCTest
import Combine

@testable import Jolt

final class JoltDeleteRequestsTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var cancellable: Cancellable?
    
    func testDELETEWithURLEncodedParameters() {
        let exp = expectation(description: "wait for completion")
        let sut = JoltNetwork(baseURL: TestConfig.httpbinBaseUrlEndPoint)
        
        sut.delete("/delete", parameters: ["userId": 25])
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Should not generate an error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { (result: Dictionary<String, Any>) in
                XCTAssertEqual(result["url"] as? String, "http://httpbin.org/delete?userId=25")
                exp.fulfill()
            }).store(in: &cancellables)
        XCTWaiter().wait(for: [exp], timeout: 5)
    }
}
