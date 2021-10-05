import XCTest
import Combine

@testable import Jolt

final class JoltGetRequestsTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var cancellable: Cancellable?
    
    let sut = JoltNetwork(baseURL: TestConfig.typicodeBaseUrlEndPoint)
    
    func test_getRequest_with_decodable_object_response() {
        let exp = expectation(description: "wait for completion")
        
        sut.get("/posts/1").sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Should not generate an error: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { (post: Post) in
            XCTAssertEqual(post.identifier, 1)
            XCTAssertEqual(post.userId, 1)
            exp.fulfill()
        }).store(in: &cancellables)
        XCTWaiter().wait(for: [exp], timeout: 5)
    }
    
    func test_getRequest_with_multipledecodable_object_response() {
        typealias Posts = [Post]
        let exp = expectation(description: "wait for completion")
        
        sut.get("/posts").sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Should not generate an error: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { (posts: Posts) in
            XCTAssertEqual(posts.count, 100)
            exp.fulfill()
        }).store(in: &cancellables)
        XCTWaiter().wait(for: [exp], timeout: 5)
    }
    
    func test_getRequest_with_params_object_response() {
        typealias Posts = [Post]
        let exp = expectation(description: "wait for completion")
        
        let params = ["userId": 1]
        sut.get("/posts", parameters: params).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Should not generate an error: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { (posts: Posts) in
            XCTAssertEqual(posts.count, 10)
            for post in posts {
                XCTAssertEqual(post.userId, 1)
            }
            exp.fulfill()
        }).store(in: &cancellables)
        XCTWaiter().wait(for: [exp], timeout: 5)
    }
    
    func test_getRequest_with_void_object_response() {
        let exp = expectation(description: "wait for completion")
        
        sut.get("/posts/1").sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Should not generate an error: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: {
            exp.fulfill()
        }).store(in: &cancellables)
        XCTWaiter().wait(for: [exp], timeout: 5)
    }
    
    
    func test_getRequest_with_data_object_response() {
        let exp = expectation(description: "wait for completion")
        
        sut.get("/posts/1").sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Should not generate an error: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { (result: Dictionary<String, Any>) in
            XCTAssertTrue(result["id"] is Int)
            XCTAssertTrue(result["id"] is Int)
            XCTAssertTrue(result["title"] is String)
            XCTAssertTrue(result["body"] is String)

            XCTAssertEqual(result["id"] as! Int, 1)
            XCTAssertEqual(result["userId"] as! Int, 1)
            exp.fulfill()
        }).store(in: &cancellables)
        XCTWaiter().wait(for: [exp], timeout: 5)
        
    }
    
    func test_getRequest_with_any_object_response() {
        
        let exp = expectation(description: "wait for completion")
        
        sut.get("/posts/1").sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Should not generate an error: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { (result: Any) in
            guard let result = result as? [String: Any] else {
                XCTFail("Should be a dictionnary")
                return
            }
            XCTAssertTrue(result["id"] is Int)
            XCTAssertTrue(result["id"] is Int)
            XCTAssertTrue(result["title"] is String)
            XCTAssertTrue(result["body"] is String)

            XCTAssertEqual(result["id"] as! Int, 1)
            XCTAssertEqual(result["userId"] as! Int, 1)
            exp.fulfill()
        }).store(in: &cancellables)
        XCTWaiter().wait(for: [exp], timeout: 5)
        
    }
}

