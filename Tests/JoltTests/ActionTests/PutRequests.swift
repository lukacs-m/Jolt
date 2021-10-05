//
//  File.swift
//  
//
//  Created by Martin Lukacs on 01/10/2021.
//

import XCTest
import Combine

@testable import Jolt

final class JoltPutRequestsTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var cancellable: Cancellable?
    
    let sut = JoltNetwork(baseURL: TestConfig.typicodeBaseUrlEndPoint)
    
    func test_patchRequest_with_decodable_object_response() {
        let exp = expectation(description: "wait for completion")
        let newTitle = "New test title"
        let newBody = "New test body"
        
        let params = [ "id": 1,
                       "title": newTitle,
                       "body": newBody,
                       "userId": 1] as [String : Any]
        
        sut.put("/posts/1", parameters: params).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Should not generate an error: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { (post: Post) in
            XCTAssertEqual(post.identifier, 1)
            XCTAssertEqual(post.title, newTitle)
            XCTAssertEqual(post.body, newBody)
            
            exp.fulfill()
        }).store(in: &cancellables)
        XCTWaiter().wait(for: [exp], timeout: 5)
    }
}
