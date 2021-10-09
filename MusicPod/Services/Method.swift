//
//  Method.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation

public struct APIMethod: RawRepresentable, Equatable, Hashable {
    /// `GET` method.
    public static let get = HTTPMethod(rawValue: "GET")
    /// `POST` method.
    public static let post = HTTPMethod(rawValue: "POST")
    
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
