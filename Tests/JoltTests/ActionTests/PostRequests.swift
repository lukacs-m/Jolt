//
//  File.swift
//  
//
//  Created by Martin Lukacs on 30/09/2021.
//

import XCTest
import Combine

@testable import Jolt

final class JoltPostRequestsTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var cancellable: Cancellable?
    
    func test_postRequest_with_decodable_object_response() {
        let exp = expectation(description: "wait for completion")
        let params = ["title": "test",
                      "body": "bodyTest",
                      "userId": 1] as [String : Any]
        let sut = JoltNetwork(baseURL: TestConfig.typicodeBaseUrlEndPoint)

        sut.post("/posts", parameters: params).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Should not generate an error: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { (post: Post) in
            XCTAssertEqual(post.title, "test")
            XCTAssertEqual(post.body, "bodyTest")
            XCTAssertEqual(post.userId, 1)
            exp.fulfill()
        }).store(in: &cancellables)
        XCTWaiter().wait(for: [exp], timeout: 5)
    }
    
    func testPOSTWithoutParameters() {
        let exp = expectation(description: "wait for completion")
        let sut = JoltNetwork(baseURL: TestConfig.typicodeBaseUrlEndPoint)

        sut.post("/posts", parameters: nil).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Should not generate an error: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { (result: Any) in
            exp.fulfill()
        }).store(in: &cancellables)
        XCTWaiter().wait(for: [exp], timeout: 5)
    }
    
    func testPOSTWithIvalidPath() {
        let exp = expectation(description: "wait for completion")
        let sut = JoltNetwork(baseURL: TestConfig.typicodeBaseUrlEndPoint)

        sut.post("/badendpoint", parameters: nil).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTAssertTrue(error is JoltNetworkErrors)
                exp.fulfill()
            case .finished:
                break
            }
        }, receiveValue: {
            XCTFail("Should generate a error")
        }).store(in: &cancellables)
        XCTWaiter().wait(for: [exp], timeout: 5)
    }
    
    func testPOSTWithMultipartFormData() {
        let sut = JoltNetwork(baseURL: TestConfig.httpbinBaseUrlEndPoint)
        
        let item1 = "FirstDataItem"
        let item2 = "SecondDataItem"
        let part1 = FormDataPart(data: item1.data(using: .utf8)!, parameterName: item1, filename: "\(item1).png")
        let part2 = FormDataPart(data: item2.data(using: .utf8)!, parameterName: item2, filename: "\(item2).png")
        let parameters = [
            "string": "valueA",
            "int": 20,
            "double": 20.0,
            "bool": true,
        ] as [String: Any]
        
        let exp = expectation(description: "wait for completion")
        
        sut.post("/post", parameters: parameters, parts: [part1, part2]).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Should not generate an error: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { (result: Dictionary<String, Any>) in
            XCTAssertEqual(result["url"] as? String, "http://httpbin.org/post")
            guard let headers = result["headers"] as? [String: Any] else {
                XCTFail()
                return
            }
            XCTAssertTrue((headers["Content-Type"] as! String).contains("multipart/form-data; boundary="))
            
            guard let files = result["files"] as? [String: Any] else {
                XCTFail("Should contain files in result")
                return
            }
            XCTAssertEqual(files[item1] as? String, item1)
            XCTAssertEqual(files[item2] as? String, item2)
            
            guard let form = result["form"] as? [String: Any] else {
                XCTFail("Should contain a form in result")
                return
            }
            XCTAssertEqual(form["string"] as? String, "valueA")
            XCTAssertEqual(form["int"] as? String, "20")
            XCTAssertEqual(form["double"] as? String, "20.0")
            XCTAssertEqual(form["bool"] as? String, "true")
            exp.fulfill()
        }).store(in: &cancellables)
        
        
        XCTWaiter().wait(for: [exp], timeout: 5)
    }
}
