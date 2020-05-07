//
//  SearchWorker.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 15/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

class SearchWorker {
    func fetchSearchList(_ q: String, completion: @escaping(SearchModel.List.Response) -> Void ) -> URLSessionTask{
        return APIClient.search(query: q) { (data, error) in
            guard error == nil else {
                let response = SearchModel.List.Response(search: [], isError: true, message: error!.localizedDescription)
                completion(response)

                return
            }
            
            var result = [Search]()
            
            if let data = data, let album = data.albums, let artist = data.artists, let playlist = data.playlists {
                if album.items.count > 0 {
                    result += album.items
                }
                
                if artist.items.count > 0 {
                    result += artist.items
                }
                
                if playlist.items.count > 0 {
                    result += playlist.items
                }
                
                result.sort { $0.name.lowercased() < $1.name.lowercased() }
            }
            
            let response = SearchModel.List.Response(search: result, isError: false, message: nil)
            completion(response)
        }
    }
    
    func fetchCoverImage(request: SearchModel.CoverImage.Request, completion: @escaping(SearchModel.CoverImage.Response) -> Void ) {
        APIClient.downloadPosterImage(path: request.url) { (data, error) in
            if let data = data {
                let entry = Entry(cover: data)
                let response = SearchModel.CoverImage.Response(entry: entry, cell: request.cell)
                completion(response)
            }
        }
    }
}
