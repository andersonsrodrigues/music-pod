//
//  LoginModels.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

enum Login {
    // MARK: Use cases
    
    enum Data {
        struct Request {}
        struct Response {
            var success: Bool
            var error: Error?
        }
        struct ViewModel {
            var success: Bool
            var error: Error?
        }
    }
}
