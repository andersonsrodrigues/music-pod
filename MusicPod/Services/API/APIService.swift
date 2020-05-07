//
//  APIService.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 11/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

typealias Response<ResponseType: Decodable> = Result<ResponseType, Error>

final class APIService {
    
    @discardableResult
    
    class func performRequest<ResponseType: Decodable>(from request: APIRouter, responseType: ResponseType.Type, completion: @escaping(Response<ResponseType>) -> Void) -> URLSessionDataTask {
        do {
            let task = URLSession.shared.dataTask(with: try request.asURLRequest()) { (data, response, error) in
                guard let data = data else {
                    let error = NSError(domain: "error data", code: 0, userInfo: nil)
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                let decoder = JSONDecoder()
                do {
                    let responseObject = try decoder.decode(ResponseType.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(responseObject))
                    }
                } catch {
                    do {
                        let errorObject = try decoder.decode(ErrorResponse.self, from: data)
                        DispatchQueue.main.async {
                            completion(.failure(errorObject.error))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
            }
            
            task.resume()
            
            return task
        } catch {
            fatalError("Error to handle the request")
        }
    }
}
