//
//  File.swift
//  
//
//  Created by Martin Lukacs on 15/09/2021.
//

import Combine

extension AnyPublisher {
    
    /// Transform a AnyPublisher into a Just publisher to send back values when needed without having to specified the type of failure.
    /// - Parameter output: The content to send through the publisher
    /// - Returns: A AnyPublisher that contains the output value and conforms to the error type.
    public static func just(_ output: Output) -> Self {
        Just(output)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }
    
    /// Creates a failure that can be sent in a publisher flow
    /// - Parameter error: The error to be sent
    /// - Returns: A failure containing the error.
    public static func isFailing(with error: Failure) -> Self {
        Fail(error: error).eraseToAnyPublisher()
    }
}
