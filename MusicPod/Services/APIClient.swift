//
//  APIClient.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation
import Alamofire

class APIClient {
    
    @discardableResult
    static func performRequest<ResponseType: Decodable>(router: APIRouter, responseType: ResponseType.Type, completion: @escaping(Result<ResponseType, AFError>) -> Void) -> DataRequest {
        return AF.request(router)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: responseType) { response in
                
                if let code = response.response?.statusCode {
                    if code >= 400 {
                        print(response.request!.allHTTPHeaderFields)
                        print(String(data: response.request!.httpBody!, encoding: .utf8))
                        print(String(data: response.data!, encoding: .utf8))
                    }
                }
                
                print(response)
                completion(response.result)
        }
    }
    
    static func perfomDownload() {
        
    }
}
