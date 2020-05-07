//
//  APIConfiguration.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation

typealias Parameters = [String: Any]

protocol APIConfiguration  {
    var method: Method { get }
    var path: String { get }
    var parameters: Parameters? { get }
    var base: String { get }
    
    func asURLRequest() throws -> URLRequest
}
