//
//  SearchResponse.swift
//  Music Finder
//
//  Created by Oleg Tsarenkoff on 19.07.21.
//

import Foundation

struct SearchResponse: Decodable {
    var resultCount: Int
    var results: [Track]
}

struct Track: Decodable {
    var artistName: String
    var trackName: String
    var collectionName: String?
    var artworkUrl100: String?
    var previewUrl: String?
}
