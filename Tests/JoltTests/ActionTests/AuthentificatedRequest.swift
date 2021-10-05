//
//  File.swift
//  
//
//  Created by Martin Lukacs on 30/09/2021.
//

import XCTest
import Combine

@testable import Jolt

final class JoltAuthorisedRequestsTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var cancellable: Cancellable?
    
    let sut = JoltNetwork(baseURL: TestConfig.httpbinBaseUrlEndPoint)
    
    func test_request_with_basic_authentification() {
        let exp = expectation(description: "wait for completion")
        sut.setAuthentificationHeader(username: "foo", password: "bar")
        
        sut.get("/basic-auth/foo/bar").sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Should not generate an error: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { (result: Dictionary<String, Any>) in
            XCTAssertEqual(result["user"] as! String, "foo")
            XCTAssertEqual(result["authenticated"] as! Bool, true)
            exp.fulfill()
        }).store(in: &cancellables)
        XCTWaiter().wait(for: [exp], timeout: 5)
    }
    
    func test_requests_with_bearer_authentification() {
        let exp = expectation(description: "wait for completion")
        sut.setAuthentificationHeader(token: "this is the bearer token")
        
        sut.get("/bearer").sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Should not generate an error: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { (result: Dictionary<String, Any>) in
            XCTAssertEqual(result["token"] as! String, "this is the bearer token")
            XCTAssertEqual(result["authenticated"] as! Bool, true)
            exp.fulfill()
        }).store(in: &cancellables)
        XCTWaiter().wait(for: [exp], timeout: 5)
    }
}
