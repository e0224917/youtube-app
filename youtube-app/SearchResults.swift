//
//  SearchResults.swift
//  youtube-app
//
//  Created by Nhat Ton on 13/2/18.
//  Copyright © 2018 Nhat Ton. All rights reserved.
//

import Foundation

class SearchResults {
    var _videoIds: [String]
    var _videoTitles: [String]
    var _selectedId: String
    
    init()
    {
        _videoIds = [String]()
        _videoTitles = [String]()
        _selectedId = ""
    }
    
    var videoIds: [String] {
        get { return _videoIds}
        set { _videoIds = newValue}
    }
    
    var videoTitles: [String] {
        get { return _videoTitles}
        set { _videoTitles = newValue}
    }
    
    var selectedId: String {
        get { return _selectedId}
        set { _selectedId = newValue}
    }
    
}
